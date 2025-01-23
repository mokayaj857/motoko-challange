# Motoko Challenge: Enhance a Decentralized Auction Dapp

## Overview
This is a coding challenge for implementing a decentralized auction system on the Internet Computer using Motoko.

## Your Tasks: 
1. Implement a function to store and retrieve auction data using stable variables. This will ensure that auction data persists across canister upgrades.
2. Create a public function that allows users to retrieve a list of all active auctions (those with remaining time > 0).
3. Implement a periodic timer that automatically closes auctions when their remaining time reaches zero. When an auction closes, it should determine the winning bid and update the auction status.
4. Add a new feature that allows the auction creator to set a reserve price. If the highest bid doesn't meet the reserve price when the auction closes, the item should not be sold.
5. Implement a function that allows users to retrieve their bidding history across all auctions.

## Evaluation criteria: 
- Evaluation Criteria
- Correct implementation of the required functionality
- Proper use of Motoko language features
- Code organization and readability
- Handling of edge cases and error conditions
- Efficiency of implemented solutions

## Getting Started:

1. Clone the repository:
```bash
git clone https://github.com/ICP-Hub-Kenya/motoko-challange
``` 

2. CD into the ``motoko-auction-challange`` directory
```bash
cd motoko-auction-challange
```

## How to Submit: 
1. Fork this repository

2. Create a new branch with your name:
```bash
git checkout -b solution/your-name
``` 

3. Implement the required functionality

4. Test your implementation:
- Deploy locally and test all features
- Include a video demo showcasing your test case
- Verify data persistence across upgrades

5. Create a submission:
- Push your solution to your fork
- Create a Pull Request to the main repository
- Include in the PR description:
   - Brief explanation of your implementation
   - Any additional features or improvements
   - Video showing the whole demo

## Resources
You can refer to the Motoko base library documentation and the Internet Computer developer documentation for assistance. The example repo and presentation slides from the KTH summer school workshop may also be helpful:
[Developer weekly update June 21, 2023](https://internetcomputer.org/blog/2023/06/21/news-and-updates/update#motoko-workshop-at-kth-summer-school)
