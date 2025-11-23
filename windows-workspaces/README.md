# Windows VSCode Workspace Files for SSH Remote Development

This directory contains VSCode workspace files configured for remote SSH development on the Okamih infrastructure servers.

## 🚀 Quick Start

1. **Install VSCode Remote SSH Extension**
   ```
   Name: Remote SSH
   Publisher: Microsoft
   ```

2. **Configure SSH Keys**
   - Ensure your SSH keys are properly configured in `~/.ssh/config`
   - Test SSH connections work: `ssh server60-backups`

3. **Open Workspace Files**
   - Double-click any `.code-workspace` file
   - VSCode will open with remote SSH connection
   - First connection may take longer for setup

## 📁 Available Workspaces

### Server Access Workspaces

| Workspace | Description | Server | Path |
|-----------|-------------|--------|------|
| `server60-dev.code-workspace` | All development projects | Server 60 | `/var/www/projects/` |

### Project-Specific Workspaces

| Workspace | Project | Server | Environment |
|-----------|---------|--------|-------------|
| `projects/servers.code-workspace` | Servers management project | Server 60 | Development |
| `projects/okamih-cz.code-workspace` | Okamih.cz website | Server 60 | Development |
| `projects/budget-control.code-workspace` | Budget control system | Server 61 | Production |

## 🔧 Configuration Details

### SSH Connection Settings
- **Server 60**: Uses sslh multiplexer on port 2260
- **Server 61**: Direct SSH on port 2261
- **Authentication**: SSH key-based (`~/.ssh/id_okamih`)

### VSCode Settings Included
- **Theme**: Default Dark Modern
- **Font**: Size 14, Tab size 2
- **Terminal**: Bash shell integration
- **Git**: Auto-fetch enabled
- **Extensions**: Remote SSH, Prettier, TypeScript, Docker, YAML

### MCP Integration
- **Cline Extension**: Enabled with MCP support
- **Auto-start**: MCP servers start automatically
- **Configuration**: Points to local MCP server configs

## 🛠️ Troubleshooting

### Connection Issues
```bash
# Test SSH connection manually
ssh server60-backups "echo 'Connection successful'"

# Check SSH config
ssh -v server60-backups
```

### VSCode Remote Issues
1. **Reload Window**: `Ctrl+Shift+P` → "Developer: Reload Window"
2. **Check Remote Status**: Bottom left corner shows connection status
3. **Reinstall Extensions**: Sometimes remote extensions need reinstallation

### Permission Issues
- Ensure SSH keys have correct permissions: `chmod 600 ~/.ssh/id_okamih`
- Check server user permissions and group memberships

## 📋 Server Information

### Server 60 (Development)
- **IP**: 192.168.1.60
- **External Access**: Port 2260 (sslh multiplexer)
- **Users**: backups (admin), agent (CLI), pavel (dev)
- **Projects**: 15+ active development projects

### Server 61 (Production)
- **IP**: 192.168.1.61
- **External Access**: Port 2261
- **Users**: agent (CLI), pavel (admin)
- **Projects**: budget-control, test environments

### Server 62 (Web Hosting)
- **IP**: 192.168.1.62
- **External Access**: Port 22
- **Users**: pavel (admin), agent (CLI)
- **Projects**: servers-check tools

## 🔐 Security Notes

- **Agent User**: Restricted CLI access, cannot modify server configuration
- **SSH Keys**: Unique keys for each server/user combination
- **No Password Auth**: All connections use SSH key authentication
- **Limited Access**: Users have project-specific permissions only

## 📞 Support

If you encounter connection issues:

1. Check SSH connectivity manually
2. Verify SSH config file syntax
3. Ensure VSCode Remote SSH extension is updated
4. Check server firewall and SSH service status

---

**Last Updated**: November 22, 2025
**SSH Config Version**: Updated with agent users and corrected ports