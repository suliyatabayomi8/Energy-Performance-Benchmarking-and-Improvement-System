# Energy Performance Benchmarking and Improvement System

A comprehensive blockchain-based system for tracking and improving building energy performance using Clarity smart contracts.

## Overview

This system provides end-to-end energy management functionality through five interconnected smart contracts:

1. **Energy Baseline Contract** - Establishes and monitors energy usage baselines
2. **Efficiency Recommendations Contract** - Manages improvement recommendations and implementation
3. **Certification System Contract** - Handles energy certifications and ratings
4. **Tenant Engagement Contract** - Gamifies energy conservation through rewards
5. **Investment Tracking Contract** - Monitors ROI and financial performance

## Features

### Energy Baseline Management
- Establish monthly energy usage baselines
- Track consumption patterns over time
- Monitor variance from established baselines
- Support for multiple building types and sizes

### Efficiency Recommendations
- AI-driven improvement suggestions
- Implementation tracking and verification
- Cost-benefit analysis for each recommendation
- Priority scoring based on impact and feasibility

### Certification Integration
- Energy Star and LEED certification tracking
- Automated rating calculations
- Compliance monitoring and reporting
- Historical certification data management

### Tenant Engagement
- Point-based reward system for energy conservation
- Leaderboards and achievement tracking
- Behavioral modification incentives
- Community challenges and competitions

### Investment Tracking
- ROI calculation for energy improvements
- Payback period analysis
- Cost tracking for all efficiency measures
- Financial performance reporting

## Contract Architecture

### Data Types
- `uint` for numerical values (energy usage, costs, ratings)
- `principal` for user and building identification
- `string-ascii` for names and descriptions
- `bool` for status flags and validation

### Security Features
- Role-based access control (admin, building-owner, tenant)
- Input validation on all public functions
- Comprehensive error handling
- Audit trails for all transactions

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js 16+ for testing
- Basic understanding of Clarity smart contracts

### Installation
\`\`\`bash
git clone <repository-url>
cd energy-benchmarking-system
npm install
clarinet check
\`\`\`

### Testing
\`\`\`bash
npm test
\`\`\`

### Deployment
\`\`\`bash
clarinet deploy
\`\`\`

## Usage Examples

### Establishing Energy Baseline
```clarity
(contract-call? .energy-baseline establish-baseline u1000 u12 u2023)
