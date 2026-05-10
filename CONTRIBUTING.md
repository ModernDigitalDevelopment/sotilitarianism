# Contributing to Sotilitarianism

Thank you for your interest in contributing to the Sotility Protocol and the Sotilitarianism philosophical framework. This project is maintained by the [Elevation Foundation](https://elevation.foundation), a 501(c)(3) nonprofit organization.

---

## Ways to Contribute

### 1. Smart Contract Development

The Sotility Protocol consists of 20 smart contracts covering governance, DeFi, identity, and cross-chain infrastructure. Contributions are welcome in the following areas:

- **Bug reports and security disclosures** — see [SECURITY.md](SECURITY.md)
- **Gas optimization** — improvements to contract efficiency without changing behavior
- **Test coverage** — unit and integration tests for the `smart-contracts/` directory
- **Documentation** — inline NatSpec comments and external docs in `smart-contracts/docs/`

### 2. Philosophical and Academic Contributions

The Sotilitarianism framework is an evolving body of work. Contributions to the `book/`, `whitepapers/`, and `manifestos/` directories are welcome:

- Critiques, extensions, or applications of Sotilitarian theory
- Academic papers citing or building on the framework
- Translations of the book or manifestos into other languages

### 3. Economic Modeling

The `economics/` directory contains the Dual-Lever Economic Model. Contributions include:

- Simulations and backtests of the token economy
- Formal economic proofs or critiques
- Comparative analyses with existing economic frameworks

---

## Development Setup

```bash
# Clone the repository
git clone https://github.com/ModernDigitalDevelopment/sotilitarianism.git
cd sotilitarianism/smart-contracts

# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test
```

---

## Contribution Process

1. **Fork** the repository and create a feature branch: `git checkout -b feature/your-feature-name`
2. **Make your changes** with clear, descriptive commits
3. **Test thoroughly** — all smart contract changes must include tests
4. **Submit a Pull Request** with a clear description of what changed and why
5. **Review** — a maintainer will review within 7 business days

---

## Code Standards

- Solidity contracts must target `^0.8.20` and use OpenZeppelin v5 imports
- Follow the existing naming conventions: `Sotility*.sol` for protocol contracts
- All public functions must have NatSpec documentation
- Maximum contract size: 24KB (EIP-170 limit)

---

## Community

- **Website:** [elevation.foundation](https://elevation.foundation)
- **Email:** contact@elevationfoundation.org
- **Philosophy:** [Read the Book](book/README.md)

---

## Code of Conduct

All contributors are expected to follow our [Code of Conduct](CODE_OF_CONDUCT.md). The Elevation Foundation is committed to building an inclusive, respectful community.

---

*The Elevation Foundation is a 501(c)(3) nonprofit. Contributions to this open-source project do not constitute financial contributions to the Foundation.*
