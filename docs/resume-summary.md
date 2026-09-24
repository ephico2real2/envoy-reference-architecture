# Résumé summary

Résumé-ready description of the work in this repository. Every figure below is
one the repository actually supports; nothing is estimated.

## Bullets

**Platform / Kubernetes Engineer — MongoDB Search gRPC Gateway (Envoy Gateway, Kubernetes Gateway API)**

- Designed and documented a reference architecture exposing a 3-replica MongoDB Search (`mongot`) StatefulSet over gRPC through Envoy Gateway, using the Kubernetes Gateway API (`Gateway`, `GRPCRoute`, `EnvoyProxy`) behind a MetalLB-assigned VIP.
- Replaced per-pod Service routing with the shared Service, so Envoy load-balances each gRPC request across all replica pod IPs via EndpointSlices. Removes a single point of failure and allows replicas to scale without a gateway change.
- Established why L7 balancing is mandatory here rather than assumed: `mongod` holds one long-lived HTTP/2 connection, which an L4 balancer pins to a single pod, and each gRPC stream stays pinned to one replica for the lifetime of the query cursor.
- Integrated the gateway as the sanctioned `mongod` to `mongot` data path through `MongoDBSearch` `spec.clusters[].loadBalancer.unmanaged`, in place of the operator's own managed Envoy, and documented the retry behaviour for `RESOURCE_EXHAUSTED` load shedding that becomes the owner's responsibility in bring-your-own mode.
- Built a dual-listener topology — h2c on :80 for pre-TLS validation, TLS on :443 for production — with TLS terminated at the gateway, and documented certificate issuance both through cert-manager (CA `ClusterIssuer`, single-host and wildcard) and manually with `openssl` against an internal CA.
- Authored a self-contained design proposal covering goals and non-goals, seven design decisions, alternatives considered, security review, a six-phase rollout plan, acceptance criteria, a risk register and sign-off.
- Automated the documentation pipeline: shell tooling that renders Mermaid sources to PNG and generates a Confluence-ready page, with guards that fail the build when a diagram is added without a name or a referenced image is missing.

### Optional, if a security line is wanted

- Wrote a read-only macOS browser-hijack audit script covering enterprise policies, configuration profiles, launch items, extension provenance, and proxy, DNS and hosts configuration, with tiered severity and CI-friendly exit codes, validated by fault injection against a synthetic compromised profile.

## Skills line

`Kubernetes · Envoy Gateway · Gateway API (GRPCRoute) · gRPC/HTTP-2 · MetalLB · MongoDB Kubernetes Operator · cert-manager · TLS/PKI · Bash · Technical writing`

## Accuracy notes

Two things to keep honest when this goes on a CV:

- The `MongoDBSearch` integration is **designed and documented, not yet applied**. The proposal is at `Status: Proposed` with the sign-off table blank, so phrase it as designed until it is deployed.
- The diagram and Confluence tooling is real, working automation, but it is documentation infrastructure rather than production code. The wording above reflects that deliberately.
