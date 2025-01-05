# HomeLab Auto-Deployment

This repository contains the configuration and scripts necessary to automatically deploy and manage my homelab using Kubernetes, with some Ansible thrown into the mix.

## Getting Started

To get started with deploying the homelab, follow these steps:

1. Clone this repository:
    ```bash
    git clone https://github.com/brandonbolton/homelab.git
    cd homelab
    ```

2. Apply the Kubernetes configurations:
    ```bash
    kubectl apply -f k8s/
    ```

3. Monitor the deployment:
    ```bash
    kubectl get pods -w
    ```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your improvements.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.