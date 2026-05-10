# Security Policy

## Supported Versions

The Sotility Protocol is currently in pre-production (testnet phase). The following versions are actively maintained:

| Version | Supported |
|---|---|
| `main` branch | Yes — active development |
| Tagged releases | Yes — critical fixes backported |

---

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

If you discover a security vulnerability in the Sotility Protocol smart contracts, please report it responsibly:

**Email:** security@elevationfoundation.org

Include in your report:
- A description of the vulnerability and its potential impact
- Steps to reproduce the issue
- Any proof-of-concept code (if applicable)
- Your suggested fix (if you have one)

**Response timeline:**
- We will acknowledge receipt within **48 hours**
- We will provide an initial assessment within **7 days**
- We will work with you on a fix and coordinated disclosure timeline

---

## Scope

The following are **in scope** for security reports:

- All 20 smart contracts in `smart-contracts/contracts/`
- Deployment scripts in `smart-contracts/scripts/`
- Token economics logic (reentrancy, overflow, access control issues)
- Oracle manipulation vulnerabilities
- Flash loan attack vectors

The following are **out of scope:**

- The website (elevation.foundation) — report via contact@elevationfoundation.org
- Third-party dependencies (OpenZeppelin) — report to them directly
- Theoretical attacks without a proof of concept

---

## Bug Bounty

The Elevation Foundation does not currently operate a formal bug bounty program. However, we recognize and publicly credit security researchers who responsibly disclose vulnerabilities. Significant findings may be eligible for a discretionary reward.

---

## Known Issues

None currently. See [GitHub Issues](https://github.com/ModernDigitalDevelopment/sotilitarianism/issues) for open non-security bugs.

---

*The Elevation Foundation — 501(c)(3) Nonprofit | EIN: 92-1042348*
