ip=$(minikube ip)

./deploy_app.sh single-pod single-pod single-pod app.py requirements.txt 5000 single-pod
./deploy_app.sh two-pod-same-node two-pod-same-node two-pod-same-node app.py requirements.txt 5000 two-pod-same-node
./deploy_app.sh hpa hpa hpa app.py requirements.txt 5000 hpa
./deploy_app.sh vpa vpa vpa app.py requirements.txt 5000 vpa
./deploy_app.sh two-container two-container two-container app.py requirements.txt 5000 two-container

sleep 10
curl $ip/single-pod/lorem
curl $ip/hpa/lorem
curl $ip/vpa/lorem
curl $ip/two-pod-same-node/lorem
curl $ip/two-container/lorem

sleep 10
echo "checking .."
curl $ip/single-pod/lorem
echo ""
cd ./analysis/
sleep 20
bash perform_analysis.sh $ip single-pod/lorem single-pod single-pod ../sample_logs/lorem/
sleep 10
cd ../

sleep 10
echo "checking .."
curl $ip/two-pod-same-node/lorem
echo ""
cd ./analysis/
sleep 20
bash perform_analysis.sh $ip two-pod-same-node/lorem two-pod-same-node two-pod-same-node ../sample_logs/lorem/
sleep 10
cd ../

sleep 10
echo "checking .."
curl $ip/hpa/lorem
echo ""
cd ./analysis/
sleep 20
bash perform_analysis.sh $ip hpa/lorem hpa hpa ../sample_logs/lorem/
sleep 10
cd ../


sleep 10
echo "checking .."
curl $ip/vpa/lorem
echo ""
cd ./analysis/
sleep 20
bash perform_analysis.sh $ip vpa/lorem vpa vpa ../sample_logs/lorem/
sleep 10
cd ../


sleep 10
echo "checking .."
curl $ip/two-container/lorem
echo ""
cd ./analysis/
sleep 20
bash perform_analysis.sh $ip two-container/lorem two-container two-container ../sample_logs/lorem/
sleep 10
cd ../


minikube node add
./deploy_app.sh two-pod-diff-node two-pod-diff-node two-pod-diff-node app.py requirements.txt 5000 two-pod-diff-node

sleep 10
echo "checking .."
curl $ip/two-pod-diff-node/lorem
echo ""
cd ./analysis/
sleep 20
bash perform_analysis.sh $ip two-pod-diff-node/lorem two-pod-diff-node two-pod-diff-node ../sample_logs/lorem/
sleep 10
cd ../

