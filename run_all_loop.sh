ip=$(minikube ip)

./deploy_app.sh single-pod single-pod single-pod app.py requirements.txt 5000 single-pod
./deploy_app.sh two-pod-same-node two-pod-same-node two-pod-same-node app.py requirements.txt 5000 two-pod-same-node
./deploy_app.sh hpa hpa hpa app.py requirements.txt 5000 hpa
./deploy_app.sh vpa vpa vpa app.py requirements.txt 5000 vpa
./deploy_app.sh two-container two-container two-container app.py requirements.txt 5000 two-container

sleep 10
curl $ip/single-pod/loop
curl $ip/hpa/loop
curl $ip/vpa/loop
curl $ip/two-pod-same-node/loop
curl $ip/two-container/loop

sleep 10
echo "checking .."
curl $ip/single-pod/loop
echo ""
cd ./analysis/
sleep 20
bash perform_analysis.sh $ip single-pod/loop single-pod single-pod ../sample_logs/loop/
sleep 10
cd ../

sleep 10
echo "checking .."
curl $ip/two-pod-same-node/loop
echo ""
cd ./analysis/
sleep 20
bash perform_analysis.sh $ip two-pod-same-node/loop two-pod-same-node two-pod-same-node ../sample_logs/loop/
sleep 10
cd ../

sleep 10
echo "checking .."
curl $ip/hpa/loop
echo ""
cd ./analysis/
sleep 20
bash perform_analysis.sh $ip hpa/loop hpa hpa ../sample_logs/loop/
sleep 10
cd ../


sleep 10
echo "checking .."
curl $ip/vpa/loop
echo ""
cd ./analysis/
sleep 20
bash perform_analysis.sh $ip vpa/loop vpa vpa ../sample_logs/loop/
sleep 10
cd ../


sleep 10
echo "checking .."
curl $ip/two-container/loop
echo ""
cd ./analysis/
sleep 20
bash perform_analysis.sh $ip two-container/loop two-container two-container ../sample_logs/loop/
sleep 10
cd ../


minikube node add
./deploy_app.sh two-pod-diff-node two-pod-diff-node two-pod-diff-node app.py requirements.txt 5000 two-pod-diff-node

sleep 10
echo "checking .."
curl $ip/two-pod-diff-node/loop
echo ""
cd ./analysis/
sleep 20
bash perform_analysis.sh $ip two-pod-diff-node/loop two-pod-diff-node two-pod-diff-node ../sample_logs/loop/
sleep 10
cd ../

