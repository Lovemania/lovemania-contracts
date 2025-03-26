# LoveMania Smart Contracts

LoveMania is a decentralized social platform built on blockchain technology, featuring its own native token (LMNA) and a social interaction system. This repository contains the smart contracts that power the LoveMania platform.

## Overview

The project consists of two main smart contracts:

1. **LoveManiaToken (LMNA)**: The native ERC20 token of the platform
2. **LoveMania**: The main platform contract handling social interactions

## Smart Contracts

### LoveManiaToken (LMNA)

- **Standard**: ERC20 with Permit functionality
- **Symbol**: LMNA
- **Initial Supply**: 1 billion tokens
- **Features**:
  - Built-in tax system (configurable up to 10%)
  - Tax fees are sent to a revenue address
  - Ownership management

### LoveMania Platform

An upgradeable smart contract (UUPS pattern) that manages the social platform's functionality:

**Features**:

- Create posts with fee-based posting system
- Like posts
- Comment on posts
- Configurable fee token and posting fee
- Fee management system

**Key Functions**:

- `createPost`: Create a new post (requires fee payment)
- `likePost`: Like an existing post
- `addComment`: Comment on an existing post
- `getComments`: Retrieve comments for a post
- `getLikers`: Get the list of users who liked a post

## Technical Requirements

- Solidity ^0.8.20
- OpenZeppelin Contracts
- OpenZeppelin Contracts Upgradeable

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.