# Tokenized Autonomous Trash Can Management System

A decentralized waste management system built on Stacks blockchain using Clarity smart contracts. This system coordinates various aspects of autonomous trash can operations including scheduling, monitoring, sorting, sanitation, and maintenance.

## System Overview

The system consists of five interconnected smart contracts that manage different aspects of waste collection:

### 1. Collection Scheduling Contract (\`collection-scheduling.clar\`)
- Coordinates pickup timing with municipal services
- Manages collection routes and schedules
- Tracks collection history and performance metrics
- Handles dynamic scheduling based on capacity levels

### 2. Overflow Detection Contract (\`overflow-detection.clar\`)
- Monitors real-time capacity levels of trash containers
- Prevents spillage through early warning systems
- Triggers emergency collection requests when needed
- Maintains capacity history and analytics

### 3. Recycling Sorting Contract (\`recycling-sorting.clar\`)
- Ensures proper waste category separation
- Validates recycling compliance
- Tracks sorting accuracy and contamination rates
- Manages recycling rewards and penalties

### 4. Odor Control Contract (\`odor-control.clar\`)
- Manages sanitation and pest prevention measures
- Monitors air quality and odor levels
- Schedules cleaning and maintenance activities
- Tracks sanitation compliance scores

### 5. Replacement Tracking Contract (\`replacement-tracking.clar\`)
- Handles damaged container identification and reporting
- Manages repair and replacement workflows
- Tracks container lifecycle and maintenance history
- Coordinates with municipal replacement services

## Features

- **Decentralized Management**: All operations recorded on blockchain for transparency
- **Token-based Incentives**: Reward system for proper waste management
- **Real-time Monitoring**: Continuous tracking of container status
- **Municipal Integration**: Seamless coordination with city services
- **Performance Analytics**: Comprehensive reporting and metrics
- **Automated Scheduling**: Smart scheduling based on usage patterns

## Contract Architecture

Each contract operates independently while maintaining data consistency through standardized data structures and events. The system uses a token-based economy to incentivize proper waste management practices.

### Key Data Structures

- **Container Registry**: Central registry of all managed containers
- **Collection Events**: Historical record of all collection activities
- **Performance Metrics**: Tracking efficiency and compliance scores
- **Token Balances**: Reward and penalty tracking for participants

## Getting Started

### Prerequisites

- Stacks blockchain node
- Clarity development environment
- Node.js for testing

### Installation

1. Clone the repository
2. Install dependencies: \`npm install\`
3. Run tests: \`npm test\`
4. Deploy contracts to Stacks testnet

### Testing

The project includes comprehensive test suites using Vitest:

\`\`\`bash
npm test
\`\`\`

Tests cover:
- Contract deployment and initialization
- Core functionality of each contract
- Edge cases and error handling
- Integration scenarios

## Usage

### For Municipal Services

1. Register containers in the system
2. Set collection schedules and routes
3. Monitor real-time container status
4. Receive automated alerts and reports

### For Residents

1. Participate in token-based reward system
2. Report issues and maintenance needs
3. Track personal waste management performance
4. Access recycling education and resources

## Token Economics

The system uses a native token to:
- Reward proper waste sorting and disposal
- Penalize contamination and misuse
- Fund maintenance and replacement activities
- Incentivize municipal service efficiency

## Contributing

Please read our contributing guidelines and submit pull requests for any improvements.

## License

This project is licensed under the MIT License.
