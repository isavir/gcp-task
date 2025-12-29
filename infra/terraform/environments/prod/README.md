# Production Environment - Free Tier Configuration

This configuration is optimized for Google Cloud Platform's free tier limits.

## Free Tier Optimizations

### GKE Cluster
- **Machine Type**: `e2-micro` (free tier eligible)
- **Node Count**: 1-2 nodes maximum
- **Disk**: 30GB `pd-standard` (within free tier limits)
- **Preemptible Nodes**: Enabled for 80% cost savings
- **Single Node Pool**: Reduced complexity

### Disabled Features (to stay within limits)
- Shielded Nodes
- Network Policy
- Binary Authorization
- Vertical Pod Autoscaling (VPA)
- Horizontal Pod Autoscaling (HPA)
- Workload Identity

### Network Configuration
- Basic firewall rules
- Cloud NAT for private subnet internet access
- Reduced Cloud Armor rate limiting

## Free Tier Limits to Monitor

1. **Compute Engine**: 1 f1-micro or e2-micro instance per month
2. **Persistent Disk**: 30GB standard persistent disk
3. **Network Egress**: 1GB per month to most regions
4. **Load Balancing**: 5 forwarding rules
5. **Cloud Armor**: Basic security policies

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Update with your project ID and region
3. Run:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Cost Monitoring

- Monitor usage in GCP Console
- Set up billing alerts
- Consider using `gcloud billing` commands to track costs
- Use `terraform destroy` when not needed to avoid charges

## Scaling Up

To enable production features when moving beyond free tier:
1. Change machine types to `e2-standard-2` or higher
2. Enable security features (shielded nodes, network policy)
3. Add Workload Identity for secure pod authentication
4. Enable autoscaling features (HPA, VPA)
5. Add additional node pools for workload separation