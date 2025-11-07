# ☀️ SolarConnect Microgrid Contract

A comprehensive blockchain-based platform for managing decentralized solar energy microgrids, enabling peer-to-peer energy trading, production tracking, and community-driven renewable energy distribution.

## 🌟 Features

### ⚡ Energy Management
- **Solar Panel Registration**: Install and track solar panels with capacity, efficiency, and location data
- **Energy Production Tracking**: Record energy generation with automatic reward calculations
- **Energy Consumption Monitoring**: Track energy usage across the microgrid network
- **Real-time Balance Management**: Monitor individual energy balances and grid statistics

### 🏘️ Microgrid Operations
- **Microgrid Creation**: Establish community energy grids with customizable parameters
- **Participant Management**: Join microgrids and track contribution/consumption patterns
- **Grid Efficiency Calculations**: Monitor grid performance and capacity utilization
- **Community Governance**: Grid managers oversee operations and maintenance

### 💼 Energy Trading Marketplace
- **Peer-to-Peer Trading**: Create energy trade listings with custom pricing and expiration
- **Automated Transactions**: Secure energy purchases with built-in fee collection
- **Market Discovery**: Browse available energy trades across different microgrids
- **Transaction History**: Complete audit trail of all energy transfers and trades

### 🔧 Maintenance & Operations
- **Panel Maintenance Scheduling**: Track maintenance cycles and panel status
- **Grid Maintenance Fund**: Platform fees support ongoing infrastructure maintenance
- **Reputation System**: Build trust through successful energy production and trading
- **Emergency Operations**: Grid status management for maintenance periods

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks smart contract development tool
- Basic understanding of Clarity smart contract language

### Installation
1. Clone this repository
2. Navigate to the project directory
3. Run `clarinet check` to verify the contract

### Usage Examples

#### Register as a User
```bash
clarinet call solarconnect register-user
```

#### Install a Solar Panel
```bash
clarinet call solarconnect install-solar-panel u5000 u85 "Rooftop Panel A1"
```
- `u5000`: Panel capacity (watts)
- `u85`: Efficiency percentage (85%)
- `"Rooftop Panel A1"`: Location description

#### Create a Microgrid
```bash
clarinet call solarconnect create-microgrid "Community Grid Alpha" u100
```
- `"Community Grid Alpha"`: Grid name
- `u100`: Grid fee (micro-STX)

#### Record Energy Production
```bash
clarinet call solarconnect record-energy-production u1 u2500
```
- `u1`: Panel ID
- `u2500`: Energy amount produced (kWh)

#### Create Energy Trade Listing
```bash
clarinet call solarconnect create-energy-trade u1000 u50 u1 u1440
```
- `u1000`: Energy amount (kWh)
- `u50`: Price per unit (micro-STX)
- `u1`: Grid ID
- `u1440`: Expires in blocks (approximately 1 day)

#### Purchase Energy
```bash
clarinet call solarconnect purchase-energy u1
```
- `u1`: Trade ID

#### Transfer Energy
```bash
clarinet call solarconnect transfer-energy 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE u500
```
- Recipient principal address
- `u500`: Energy amount (kWh)

## 📊 Smart Contract Functions

### Public Functions
- `register-user()` - Register as a platform participant
- `install-solar-panel(capacity, efficiency, location)` - Add solar panel to the network
- `create-microgrid(name, grid-fee)` - Establish a new microgrid
- `join-microgrid(grid-id)` - Join an existing microgrid
- `record-energy-production(panel-id, amount)` - Log energy generation
- `consume-energy(amount)` - Record energy consumption
- `create-energy-trade(amount, price-per-unit, grid-id, expires-in)` - List energy for sale
- `purchase-energy(trade-id)` - Buy energy from marketplace
- `transfer-energy(recipient, amount)` - Send energy to another user
- `schedule-panel-maintenance(panel-id)` - Mark panel for maintenance
- `complete-panel-maintenance(panel-id)` - Restore panel to active status
- `update-platform-fee(new-rate)` - Admin function to adjust platform fees

### Read-Only Functions
- `get-user-data(user)` - Retrieve user profile information
- `get-panel-data(panel-id)` - Get solar panel details
- `get-microgrid-data(grid-id)` - Fetch microgrid information
- `get-trade-data(trade-id)` - View energy trade listing details
- `get-transaction-data(transaction-id)` - Access transaction history
- `get-grid-participant(grid-id, participant)` - Check participation status
- `get-platform-stats()` - View overall platform metrics
- `calculate-grid-efficiency(grid-id)` - Compute grid performance metrics
- `get-energy-balance(user)` - Check individual energy balance

## 🏗️ System Architecture

### Data Structures
- **Users**: Energy balances, reputation, production/consumption totals, rewards
- **Solar Panels**: Ownership, capacity, efficiency, location, maintenance status
- **Microgrids**: Management, capacity, participants, fees, operational status
- **Energy Trades**: Marketplace listings with pricing, expiration, and status
- **Transactions**: Complete history of energy transfers and purchases

### Economic Model
- **Platform Fee**: 2.5% fee on energy trades supports platform maintenance
- **Rewards System**: Energy producers earn rewards based on panel efficiency
- **Reputation Building**: Successful participation increases user reputation
- **Grid Fees**: Customizable fees support local microgrid operations

## 🛡️ Security Features

- **Ownership Validation**: Only panel owners can record production and schedule maintenance
- **Balance Verification**: Prevents energy transfers exceeding available balance
- **Trade Expiration**: Automatic expiry of energy trade listings
- **Authorization Controls**: Admin functions restricted to contract owner
- **Input Validation**: Comprehensive checks on all user inputs

## 🌱 Future Enhancements

- **Weather Integration**: Automatic production estimates based on weather data
- **Smart Grid Automation**: AI-powered energy distribution optimization
- **Carbon Credit Integration**: Earn carbon credits for renewable energy production
- **Mobile App Interface**: User-friendly mobile application for easy management
- **Grid Interconnection**: Connect multiple microgrids for broader energy sharing
- **Energy Storage Management**: Battery system integration for energy storage
- **Dynamic Pricing**: Market-driven pricing based on supply and demand

## 📈 Platform Metrics

The contract tracks comprehensive metrics including:
- Total energy produced and consumed across all grids
- Number of active solar panels and microgrids
- Platform maintenance fund status
- User participation and reputation statistics
- Transaction volume and trading activity

## 🤝 Contributing

This smart contract provides the foundation for a decentralized renewable energy ecosystem. Contributions welcome for additional features, optimizations, and integrations.

## 📄 License

Open source - ready for community development and deployment on the Stacks blockchain.

---

**⚡ Empowering communities through decentralized renewable energy! ☀️**
