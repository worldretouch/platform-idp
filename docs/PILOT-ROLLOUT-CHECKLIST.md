# Pilot Rollout Checklist (2 Teams)

Use this checklist to validate launch readiness with two pilot teams before GA.

## Pilot Setup

- Team A: backend-heavy service (Go/Node preferred)
- Team B: framework-heavy service (Rails/Python preferred)
- Pilot duration: 1 sprint
- Success metric owner: platform team

## Team Onboarding Checklist

- [ ] Team has access to service repo + env repo + ArgoCD dashboards
- [ ] Team completed `docs/ONBOARDING-30-MINUTES.md`
- [ ] Team created a new service from template
- [ ] Team ran service locally using `make init && make run`
- [ ] Team validated health + observability headers/logs

## Delivery Checklist

- [ ] Reusable CI is wired and green
- [ ] Security scans and parity checks are passing
- [ ] SBOM artifact generated for release build
- [ ] Cosign sign + verify passed in pipeline
- [ ] Dev values PR automation worked
- [ ] ArgoCD sync to dev successful

## Promotion Checklist

- [ ] Team promoted dev -> staging via PR
- [ ] Team promoted staging -> prod via production promotion workflow
- [ ] Prod promotion required signature verification
- [ ] Rollback drill executed once and documented

## Feedback Checklist

- [ ] Time-to-first-deploy recorded (minutes)
- [ ] Friction points captured (tooling/docs/pipeline)
- [ ] Missing template capability identified
- [ ] Required platform support tickets counted

## Exit Criteria for Pilot

- [ ] Both teams deploy without direct DevOps intervention
- [ ] Both teams complete one safe rollback
- [ ] No critical pipeline/security gap remains open
- [ ] Improvement backlog is prioritized for next sprint

