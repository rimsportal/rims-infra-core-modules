# v0.6.0 release notes

This release adds the reusable capabilities required by DT Factory while leaving consumers pinned to `v0.5.0` unchanged.

- App Service can reuse an existing plan and optionally configure Microsoft Entra authentication and CORS.
- Spoke networking can run standalone without mandatory hub peering.
- PostgreSQL supports private-only access, backup retention, optional HA, and enforced TLS.
- Key Vault supports explicit public-network control with RBAC.
- Storage supports identity-first access, private-data controls, versioning, and soft delete.
- New workspace-based monitoring and resource-group budget modules are included.

The new module behavior is validated with AzureRM `~> 4.0`. Existing Portal deployments should remain pinned to `v0.5.0` until they are intentionally upgraded and tested.
