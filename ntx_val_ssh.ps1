# Import SSH module if not loaded
Install-Module -Name Posh-SSH -Force

# Define CVM connection parameters
$CVM_IP = "10.11.0.65"
$Username = "nutanix"
$Password = "nutanix/4u"

# Create a secure password object
$SecurePass = ConvertTo-SecureString $Password -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($Username, $SecurePass)

# Create SSH session
$SshSession = New-SSHSession -ComputerName $CVM_IP -Credential $Cred

# Create SSH session
$SshSession2 = New-SSHSession -ComputerName $CVM_IP -Credential $Cred

# Create SSH session
$SshSession3 = New-SSHSession -ComputerName $CVM_IP -Credential $Cred

#ethtool cmd 
$cmd2 = 'for i in $(/usr/local/nutanix/cluster/bin/svmips); do ssh nutanix@$i "source /etc/profile; ~/ncc/bin/ncc hardware_info show_hardware_info"; done'
$cmd3 = 'for i in $(source /etc/profile; /usr/local/nutanix/cluster/bin/hostips); do ssh root@$i "echo ============ ethtool -m =============; echo ============= $i =============; echo eth0; /usr/sbin/ethtool -m eth0; echo eth1; /usr/sbin/ethtool -m eth1; echo eth2; /usr/sbin/ethtool -m eth2; echo eth3; /usr/sbin/ethtool -m eth3; echo eth4; /usr/sbin/ethtool -m eth4; echo eth5; /usr/sbin/ethtool -m eth5; echo eth6; /usr/sbin/ethtool -m eth6; echo eth7; /usr/sbin/ethtool -m eth7 "; done'

# Define multiple commands separated by semicolon
$commands = @(
  "/home/nutanix/prism/cli/ncli cluster get-params",
  "/usr/local/nutanix/bin/acli host.list",
  "/usr/local/nutanix/cluster/bin/hostssh virsh list | grep -i 'ntnx'",
  "/usr/local/nutanix/cluster/bin/svmips -d",
  "/home/nutanix/prism/cli/ncli host ls",
  "source /etc/profile; /usr/local/nutanix/apache-cassandra/bin/nodetool -h 0 ring",
  "/home/nutanix/prism/cli/ncli multicluster get-cluster-state",
  "/home/nutanix/prism/cli/ncli cluster get-domain-fault-tolerance-status type=node",
  "/home/nutanix/prism/cli/ncli cluster get-redundancy-state",
  "cat /home/nutanix/cluster/config/lcm/version.txt",
  "cat /home/nutanix/foundation/foundation_version",
  "~/ncc/bin/ncc --version",
  "/home/nutanix/prism/cli/ncli http-proxy ls",   
  "/home/nutanix/prism/cli/ncli cluster get-name-servers",
  "/home/nutanix/prism/cli/ncli cluster get-ntp-servers",
  "/home/nutanix/prism/cli/ncli cluster get-smtp-server",
  "/home/nutanix/prism/cli/ncli alert ls",
  "/home/nutanix/prism/cli/ncli alerts get-alert-config",
  "/usr/local/nutanix/bin/acli net.list",
  "/home/nutanix/prism/cli/ncli container ls",
  "/home/nutanix/prism/cli/ncli sp list",
  "/home/nutanix/prism/cli/ncli disk ls",
  "/home/nutanix/prism/cli/ncli pulse-config list",
  "/home/nutanix/prism/cli/ncli license get-license",
  "/home/nutanix/prism/cli/ncli authconfig get-client-authentication-config",
  "/home/nutanix/prism/cli/ncli authconfig list",
  "/home/nutanix/prism/cli/ncli authconfig list-role-mappings name=Cibil",
  "/home/nutanix/prism/cli/ncli authconfig list-directory",
  "/home/nutanix/prism/cli/ncli http-proxy get-whitelist",
  "/home/nutanix/prism/cli/ncli cluster get-smtp-server",
  "/usr/local/nutanix/cluster/bin/hostssh 'ovs-vsctl list port br0-up'",
  "source /etc/profile; ~/ncc/panacea/bin/panacea_cli cssh manage_ovs show_interfaces",
  "source /etc/profile; ~/ncc/panacea/bin/panacea_cli cssh manage_ovs show_uplinks",
  "/usr/local/nutanix/cluster/bin/hostssh 'lldpctl | grep -e Interface -e SysName -e PortID'",
  "/usr/local/nutanix/cluster/bin/hostssh 'ipmitool lan print 1 | grep ""MAC Address""'",
  "/home/nutanix/prism/cli/ncli cluster get-cvm-security-config",
  "/home/nutanix/prism/cli/ncli cluster get-hypervisor-security-config",
  "/usr/local/nutanix/cluster/bin/hostssh 'lspci | grep -I net'",
  "source /etc/profile; ~/ncc/panacea/bin/panacea_cli cssh uptime",
  "/usr/local/nutanix/cluster/bin/hostssh last reboot",
  "/usr/local/nutanix/cluster/bin/hostssh cat /var/log/upgrade_history.log",
  "source /etc/profile; ~/ncc/panacea/bin/panacea_cli cssh  cat ~/config/upgrade.history",
  "source /etc/profile; ~/ncc/bin/ncc health_checks run_all"
)

# Run commands and append output to file
$outputFile = "cvm-10.11.0.65-validation_out.txt"
foreach ($cmd in $commands) {
   # Write a separator line with the command
   "-------------------------" | Out-File -FilePath $outputFile -Append
   "Command: $cmd" | Out-File -FilePath $outputFile -Append
   "-------------------------" | Out-File -FilePath $outputFile -Append

   # Run the command and write results
   $result = Invoke-SSHCommand -SSHSession $SshSession -Command $cmd -TimeOut 300
   $result.Output | Out-File -FilePath $outputFile -Append

   # Add a blank line afterward
   "" | Out-File -FilePath $outputFile -Append
}

# Remove SSH session
Remove-SSHSession -SSHSession $SshSession

#Second ssh command to capture hardware info
$result2 = Invoke-SSHCommand -SSHSession $SshSession2 -Command $cmd2 -TimeOut 600
$result2.Output | Out-File -FilePath $outputFile -Append

# Remove SSH session
Remove-SSHSession -SSHSession $SshSession2

#Third ssh command to capture network info 
$result3 = Invoke-SSHCommand -SSHSession $SshSession3 -Command $cmd3 -TimeOut 600
$result3.Output | Out-File -FilePath $outputFile -Append

# Remove SSH session
Remove-SSHSession -SSHSession $SshSession3

#clean up POSH-SSH
Uninstall-Module -Name Posh-SSH -Force