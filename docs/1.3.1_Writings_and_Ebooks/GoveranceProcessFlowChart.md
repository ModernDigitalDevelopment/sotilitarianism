# Appendix C: Governance Process Flowchart

## 1. Multi-Layered Governance Framework

The Sotility governance system operates across three interconnected layers:

```
┌───────────────────────────────────────────────────────────────────────────┐
│                         SOTILITY GOVERNANCE STACK                          │
└───────────────────────────────────────────────────────────────────────────┘
                                     │
          ┌─────────────────────────┼─────────────────────────┐
          │                         │                         │
┌─────────▼─────────┐     ┌─────────▼─────────┐     ┌─────────▼─────────┐
│  PROTOCOL-LEVEL   │     │  COMMUNITY-LEVEL  │     │   CONTENT-LEVEL   │
│    GOVERNANCE     │     │    GOVERNANCE     │     │    GOVERNANCE     │
└─────────┬─────────┘     └─────────┬─────────┘     └─────────┬─────────┘
          │                         │                         │
┌─────────▼─────────┐     ┌─────────▼─────────┐     ┌─────────▼─────────┐
│• System parameters│     │• Local DAO voting  │     │• Content scoring  │
│• Treasury usage   │     │• Community rules   │     │• Reward allocation│
│• Contract upgrades│     │• Resource allocation│    │• Dispute resolution│
│• Emergency actions│     │• Member admission  │     │• Badge issuance   │
└───────────────────┘     └───────────────────┘     └───────────────────┘
```

## 2. Decision-Making Process

### 2.1 Protocol-Level Governance Flow

```
┌───────────┐     ┌───────────┐     ┌───────────┐     ┌───────────┐
│  Proposal │────►│   Signal  │────►│  Formal   │────►│ TimeGap   │
│ Creation  │     │  Voting   │     │   Vote    │     │  Period   │
└───────────┘     └───────────┘     └───────────┘     └─────┬─────┘
                                                            │
┌───────────┐     ┌───────────┐     ┌───────────┐     ┌─────▼─────┐
│Transaction│◄────│  Action   │◄────│  Executor │◄────│  Quorum   │
│ Execution │     │ Queueing  │     │ Selection │     │  Check    │
└───────────┘     └───────────┘     └───────────┘     └───────────┘
```

#### Detailed Decision-Making Steps:

1. **Proposal Creation**
   - Created by any user with minimum threshold of veSOT tokens (locked SOT)
   - Must include detailed action plan, code changes, and impact analysis
   - Requires minimum of 100,000 veSOT to submit

2. **Signal Voting (Temperature Check)**
   - 3-day period for community feedback and modifications
   - Non-binding voting to gauge sentiment
   - Automatic advancement threshold: 55% approval with at least 5% of veSOT participating

3. **Formal Vote**
   - 7-day binding voting period
   - Vote weight determined by veSOT balance
   - Quadratic voting option for specific proposal types

4. **TimeGap Period**
   - 2-day waiting period before implementation (if approved)
   - Allows time for community to prepare for changes
   - Emergency proposals can bypass with supermajority approval

5. **Quorum Check**
   - Minimum participation requirements:
     - Minor changes: 5% of total veSOT
     - Major changes: 15% of total veSOT
     - Critical/emergency: 25% of total veSOT

6. **Executor Selection**
   - Technical implementation team assigned based on proposal type
   - For contract upgrades: MultiSig wallet controlled by Guardian Committee

7. **Action Queueing**
   - Actions are queued in the ProposalManager contract
   - Timelock enforced for security
   - Transaction parameters verified by off-chain validators

8. **Transaction Execution**
   - Automated execution after timelock expires
   - Results posted on-chain with transparency hash
   - Action completion events emitted

### 2.2 Community-Level Governance Flow

```
┌──────────────┐     ┌───────────┐     ┌───────────┐     ┌───────────┐
│ Local Proposal│────►│Community  │────►│ Snapshot  │────►│  Action   │
│   Creation    │     │Discussion │     │   Vote    │     │Assignment │
└──────────────┘     └───────────┘     └───────────┘     └─────┬─────┘
                                                               │
                                                         ┌─────▼─────┐
                                                         │ Execution  │
                                                         │ & Reporting │
                                                         └───────────┘
```

### 2.3 Content-Level Governance Flow

```
┌───────────┐     ┌───────────┐     ┌───────────┐     ┌───────────┐
│  Content  │────►│ AI Oracle │────►│  Human    │────►│  Reward   │
│Submission │     │ Evaluation│     │Verification│     │Calculation│
└───────────┘     └───────────┘     └───────────┘     └─────┬─────┘
                                                            │
                                                      ┌─────▼─────┐
                                                      │   Token   │
                                                      │ Issuance  │
                                                      └───────────┘
```

## 3. Governance Participants and Roles

### 3.1 Voting Rights Allocation

| Participant Type | Primary Token | Voting Weight Formula | Scope of Authority |
|------------------|---------------|------------------------|-------------------|
| SOT Holders | SOT/veSOT | Base voting weight × lock time multiplier | Protocol-wide changes, treasury actions |
| Community DAO Members | Local DAO token | Equal voting rights per token | Community-specific decisions, local resource allocation |
| Content Contributors | SUG | Reputation-weighted impact score | Content validation, dispute resolution |
| Specialized Committees | Badge NFTs | Expert designation weight | Technical decisions, emergency response |

### 3.2 Guardian Committee Structure

```
┌──────────────────────────────────────────────────────────────┐
│                     GUARDIAN COMMITTEE                        │
└──────────────────────────────────────────────────────────────┘
                              │
         ┌──────────────────┬─┴─┬──────────────────┐
         │                  │   │                  │
┌────────▼─────────┐ ┌──────▼───▼──────┐ ┌─────────▼────────┐
│ Technical Guard  │ │ Economic Guard  │ │  Social Guard    │
│ (5 members)      │ │ (5 members)     │ │  (5 members)     │
└──────────────────┘ └─────────────────┘ └──────────────────┘
         │                  │                  │
┌────────▼─────────┐ ┌──────▼───────────┐ ┌───▼──────────────┐
│• Code reviews     │ │• Financial risks  │ │• Content policies│
│• Security audits  │ │• Treasury actions │ │• Dispute resolution│
│• Emergency fixes  │ │• Market stability │ │• Community safety│
└──────────────────┘ └──────────────────┘ └──────────────────┘
```

### 3.3 Delegation Mechanics

The Sotility ecosystem supports governance delegation:

- **Direct Delegation**: Token holders can delegate their voting power to trusted representatives
- **Fractional Delegation**: Voting power can be split among multiple delegates
- **AI Delegate Program**: Optional AI-assisted voting based on holder-defined preferences
- **Liquid Democracy**: Delegates can re-delegate received voting power (up to 2 levels deep)

## 4. Dispute Resolution Framework

```
┌───────────┐     ┌───────────┐     ┌───────────┐     ┌───────────┐
│  Dispute  │────►│ Evidence  │────►│  Review   │────►│  Decision │
│ Initiation│     │ Collection│     │  Process  │     │ Issuance  │
└───────────┘     └───────────┘     └───────────┘     └─────┬─────┘
                                                            │
┌───────────┐     ┌───────────┐                       ┌─────▼─────┐
│   Case    │◄────│  Appeal   │◄──────────────────────│Enforcement│
│  Closure  │     │ (Optional)│                       │           │
└───────────┘     └───────────┘                       └───────────┘
```

## 5. Incentive Alignment Mechanisms

The Sotility governance framework incorporates multiple incentive alignment mechanisms:

### 5.1 Long-Term Incentives

- Time-weighted voting (veToken model) rewards long-term commitment
- Proposal creators receive reputation badges for successful implementations
- Governance participation earns SUG tokens proportional to quality of input

### 5.2 Skin-in-the-Game Mechanisms

- Critical proposals require escrowed tokens from proposers
- Malicious proposals can result in forfeiture of escrowed tokens
- Security committee members stake tokens against their decisions

### 5.3 Reputation-Based Influence

- Contribution history impacts vote weight through on-chain reputation
- SoulBound tokens representing expertise increase influence in specific domains
- Successful proposals increase creator's influence weight for future governance

## 6. Progressive Decentralization Roadmap

The governance system will evolve through three distinct phases:

### Phase 1: Foundation (Months 0-6)
- Core team retains admin keys for rapid iteration
- Guardian Committee reviews all significant changes
- Community proposals are advisory only

### Phase 2: Delegation (Months 7-18)
- Admin functions transferred to timelock contracts
- Multi-sig guardian committee has veto powers
- Community voting becomes binding for predefined domains

### Phase 3: Autonomy (Months 19+)
- Full on-chain governance for all protocol parameters
- Guardian committee transitions to elected positions
- Emergency powers limited to extreme circumstances with super-majority approval

This progressive approach ensures stability during early development while establishing full community ownership as the ecosystem matures.