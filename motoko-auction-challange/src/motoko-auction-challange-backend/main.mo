import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Int "mo:base/Int";
import Time "mo:base/Time";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Result "mo:base/Result";
import Principal "mo:base/Principal";

actor AuctionSystem {
    // Define the Auction type
    type Auction = {
        id : Nat;
        creator : Principal;
        item : Text;
        reservePrice : Nat;
        highestBid : Nat;
        highestBidder : ?Principal;
        startTime : Time.Time;
        duration : Nat; // Duration in seconds
        isClosed : Bool;
    };

    // Define a Bid type
    type Bid = {
        auctionId : Nat;
        bidder : Principal;
        amount : Nat;
        timestamp : Time.Time;
    };

    // Stable variables
    stable var auctions : [Auction] = [];
    stable var bids : [Bid] = [];
    stable var nextAuctionId : Nat = 0;

    // Error types for better error handling
    type CreateAuctionError = {
        #InvalidDuration;
        #InvalidReservePrice;
    };

    type PlaceBidError = {
        #AuctionNotFound;
        #AuctionClosed;
        #BidTooLow;
        #InvalidBidder;
    };

    // Add a new auction with error handling
    public shared ({ caller }) func createAuction(
        item : Text,
        reservePrice : Nat,
        duration : Nat
    ) : async Result.Result<Nat, CreateAuctionError> {
        if (duration == 0) {
            return #err(#InvalidDuration);
        };
        if (reservePrice == 0) {
            return #err(#InvalidReservePrice);
        };

        let auction : Auction = {
            id = nextAuctionId;
            creator = caller;
            item = item;
            reservePrice = reservePrice;
            highestBid = 0;
            highestBidder = null;
            startTime = Time.now();
            duration = duration;
            isClosed = false;
        };
        auctions := Array.append(auctions, [auction]);
        nextAuctionId += 1;
        return #ok(auction.id);
    };

    // Retrieve all active auctions
    public query func getActiveAuctions() : async [Auction] {
        let now = Time.now();
        Array.filter(auctions, func(a : Auction) : Bool {
            !a.isClosed and (now < a.startTime + a.duration * 1_000_000_000); // Convert duration to nanoseconds
        });
    };

    // Function to close expired auctions
    func closeExpiredAuctions() : async () {
        let now = Time.now();
        for (auction in auctions.vals()) {
            if (!auction.isClosed and now >= auction.startTime + auction.duration * 1_000_000_000) {
                let updatedAuction = {
                    id = auction.id;
                    creator = auction.creator;
                    item = auction.item;
                    reservePrice = auction.reservePrice;
                    highestBid = auction.highestBid;
                    highestBidder = auction.highestBidder;
                    startTime = auction.startTime;
                    duration = auction.duration;
                    isClosed = true;
                };
                auctions := Array.map(auctions, func(a : Auction) : Auction {
                    if (a.id == auction.id) updatedAuction else a;
                });

                // Check if the highest bid meets the reserve price
                if (updatedAuction.highestBid >= updatedAuction.reservePrice) {
                    Debug.print("Auction " # Int.toText(updatedAuction.id) # " sold to " # Principal.toText(updatedAuction.highestBidder!) # " for " # Int.toText(updatedAuction.highestBid) # " ICP.");
                } else {
                    Debug.print("Auction " # Int.toText(updatedAuction.id) # " did not meet the reserve price.");
                }
            }
        };
    };

    // Set up a periodic timer to check for expired auctions
    public func startTimer() : async () {
        let _ = Timer.recurringTimer(#seconds 10, closeExpiredAuctions); // Check every 10 seconds
    };

    // Function to place a bid with error handling
    public shared ({ caller }) func placeBid(
        auctionId : Nat,
        amount : Nat
    ) : async Result.Result<(), PlaceBidError> {
        let auction = Array.find(auctions, func(a : Auction) : Bool { a.id == auctionId });
        switch (auction) {
            case null { return #err(#AuctionNotFound); }; // Auction not found
            case (?a) {
                if (a.isClosed) {
                    return #err(#AuctionClosed);
                };
                if (amount <= a.highestBid) {
                    return #err(#BidTooLow);
                };
                if (caller == a.creator) {
                    return #err(#InvalidBidder); // Auction creator cannot bid on their own auction
                };

                bids := Array.append(bids, [{
                    auctionId = auctionId;
                    bidder = caller;
                    amount = amount;
                    timestamp = Time.now();
                }]);

                let updatedAuction = {
                    id = a.id;
                    creator = a.creator;
                    item = a.item;
                    reservePrice = a.reservePrice;
                    highestBid = amount;
                    highestBidder = ?caller;
                    startTime = a.startTime;
                    duration = a.duration;
                    isClosed = a.isClosed;
                };
                auctions := Array.map(auctions, func(a : Auction) : Auction {
                    if (a.id == auctionId) updatedAuction else a;
                });
                return #ok;
            };
        };
    };

    // Function to retrieve bidding history for a user
    public query func getBiddingHistory(user : Principal) : async [Bid] {
        Array.filter(bids, func(b : Bid) : Bool { b.bidder == user });
    };
};
