# Tips and Tricks

## Submodules

### Update submodules

Location: scripts/update_submodules.sh

### Cleaning a Dirty Subodule Reference

#### Option 1: Restore the submodule to the commit expected by the parent repo This is the safest way to undo any modifications and ensure the submodule is exactly where the main repo expects it to be

```bash
cd /home/b0nz1cu5/Development/IH/ih-hand-sanitation-www
git submodule update --init -- src/app/web-header
```

#### Option 2: Discard all uncommitted changes directly within the submodule If Option 1 doesn't clear the modified state (for example, if you have untracked files or just edited local files), you can change into the directory and restore it

```bash
cd /home/b0nz1cu5/Development/IH/ih-hand-sanitation-www/src/app/web-header
git restore .
git clean -fd  # Use this if you accidentally added new untracked files
```

**Please run the following commands to verify everything is working locally:**
```bash
terraform fmt
terraform validate
terraform plan -var-file=envs/dev.tfvars
```