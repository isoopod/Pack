---
sidebar_position: 4
---

# Configuration

## pack-config.toml

For Rojo users, directly under ReplicatedStorage you can create a `pack-config.toml` file to control Pack's behaviour. Below are all the settings used by Pack.

```toml
[debug]
enabled = true
onlyInStudio = true # Should debug only be enabled in studio?
verbose = false # Do we want verbose output (not recommended)
```

Libraries built on top of Pack may implement their own settings, or borrow from these settings.

## pack-config ModuleScript

If you aren't using Rojo, we use a different format for the settings. Create a Module called `pack-config` in ReplicatedStorage.

```lua
return {
    debug = {
        enabled = true,
        onlyInStudio = true,
        verbose = false
    }
}
```
