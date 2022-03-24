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
      - 128.28.28.1-128.28.28.20
EOF

kubectl  --kubeconfig=/etc/kubernetes/admin.conf apply -f /vagrant/metalconfig.yml

cat <<EOF | sudo tee /vagrant/nginxconfigmap.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: index-html-configmap
  namespace: default
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
    <title>FRR</title>
    </head>
    <body>

    <h1>FRR is load balancing</h1>
    <p>Metallb + FRR setup.</p>

    </body>
    </html>
EOF

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
        volumeMounts:
          - name: nginx-index-file
            mountPath: /usr/share/nginx/html/
      volumes:
      - name: nginx-index-file
        configMap:
          name: index-html-configmap
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

sudo kubectl  --kubeconfig=/etc/kubernetes/admin.conf apply -f /vagrant/nginxconfigmap.yml
sudo kubectl  --kubeconfig=/etc/kubernetes/admin.conf apply -f /vagrant/nginxdeployment.yml
sudo kubectl  --kubeconfig=/etc/kubernetes/admin.conf apply -f /vagrant/nginxservice.yml
