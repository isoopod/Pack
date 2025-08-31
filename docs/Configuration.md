---
sidebar_position: 5
---

# Configuration

## pack-config.toml

For Rojo users, directly under ReplicatedStorage you can create a `pack-config.toml` file to control Pack's behaviour. Below are all the settings used by Pack with their default values.

```toml
persistInstanceRefs = false # Are we making use of Pack.Instance in a place using AssetService:SavePlaceAsync()? This allows refs to persist between sessions.

[debug]
enabled = false
onlyInStudio = true # Should debug only be enabled in studio?
verbose = false # Do we want verbose output (not recommended)
```

Libraries built on top of Pack may implement their own settings, or borrow from these settings.

## pack-config ModuleScript

If you aren't using Rojo, we use a different format for the settings. Create a Module called `pack-config` in ReplicatedStorage.

```lua
-- See the corresponding entry in the pack-config.toml section for an explaination of the setting
return {
    persistInstanceRefs = false,
    debug = {
        enabled = false,
        onlyInStudio = true,
        verbose = false
    },
}
```

---

:::note
All entries of the pack-config TOML or module are optional. Booleans default to false unless otherwise stated.
:::
