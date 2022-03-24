sudo kubectl  --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

sudo kubectl  --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/namespace.yaml
sudo kubectl  --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/metallb/metallb/v0.12.1/manifests/metallb.yaml

cat <<EOF | sudo tee /vagrant/metalconfig.yml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    peers:
    - peer-address: 172.42.42.100
      peer-asn: 64600
      my-asn: 64600
    address-pools:
    - name: default
      protocol: bgp
      addresses:
      - 126.23.45.1-126.23.45.20
EOF

kubectl  --kubeconfig=/etc/kubernetes/admin.conf apply -f /vagrant/metalconfig.yml

cat <<EOF | sudo tee /vagrant/nginxdeployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80
EOF

cat <<EOF | sudo tee /vagrant/nginxservice.yml
apiVersion: v1
kind: Service
metadata:
  name: my-nginx
  labels:
    run: my-nginx
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: my-nginx
  type: LoadBalancer
EOF

sudo kubectl  --kubeconfig=/etc/kubernetes/admin.conf apply -f /vagrant/nginxdeployment.yml
sudo kubectl  --kubeconfig=/etc/kubernetes/admin.conf apply -f /vagrant/nginxservice.yml
