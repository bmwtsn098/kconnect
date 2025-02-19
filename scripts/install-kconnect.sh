#!/bin/bash  

set -e 

echo "creating directory kconnect"
mkdir -p kconnect
cd kconnect

latest_kconnect_release_tag=$(curl -fsSLI -o /dev/null -w %{url_effective} https://github.com/fidelity/kconnect/releases/latest | sed 's#.*/##')
latest_helm_release_tag=$(curl -fsSLI -o /dev/null -w %{url_effective} https://github.com/helm/helm/releases/latest | sed 's#.*/##')
latest_kubectl_release_tag=$(curl -k -L --silent https://dl.k8s.io/release/stable.txt)
latest_kubelogin_release_tag=$(curl -fsSLI -o /dev/null -w %{url_effective} https://github.com/Azure/kubelogin/releases/latest | sed 's#.*/##')
aws_iam_authenticator_release_tag="0.5.5"

echo "kconnect version: $latest_kconnect_release_tag"
echo "kubectl version: $latest_kubectl_release_tag"
echo "helm version: $latest_helm_release_tag"
echo "kubelogin version: $latest_kubelogin_release_tag"
echo "aws-iam-authenticator version: $aws_iam_authenticator_release_tag"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # linux
    #arch=$(dpkg --print-architecture)
    arch_output=$(uname -m)
    arch=""
    case $arch_output in

        x86_64)
        arch="amd64"
        ;;

        aarch64)
        arch="arm64"
        ;;

        aarch)
        arch="arm"
        ;;

    esac

    echo "arch: " $arch

    kconnect_url=$(echo "https://github.com/fidelity/kconnect/releases/download/TAG/kconnect_linux_ARCH.tar.gz" | sed "s/TAG/$latest_kconnect_release_tag/" | sed "s/ARCH/$arch/" )
    kubectl_url=$(echo "https://dl.k8s.io/release/TAG/bin/linux/ARCH/kubectl" | sed "s/TAG/$latest_kubectl_release_tag/" | sed "s/ARCH/$arch/" )
    helm_url=$(echo "https://get.helm.sh/helm-TAG-linux-ARCH.tar.gz" | sed "s/TAG/$latest_helm_release_tag/" | sed "s/ARCH/$arch/" )
    aws_iam_authenticator_url=$(echo "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/vTAG/aws-iam-authenticator_TAG_linux_ARCH" | sed "s/TAG/$aws_iam_authenticator_release_tag/g" | sed "s/ARCH/$arch/" )
    kubelogin_url=$(echo "https://github.com/Azure/kubelogin/releases/download/TAG/kubelogin-linux-amd64.zip" | sed "s/TAG/$latest_kubelogin_release_tag/")

    echo "kconnect url: $kconnect_url" 
    echo "kubectl url: $kubectl_url"
    echo "helm url: $helm_url"
    echo "aws_iam_authenticator url: $aws_iam_authenticator_url"
    echo "kubelogin url: $kubelogin_url"
    
    # download 
    curl -s -L $kconnect_url -o kconnect.tar.gz
    curl -s -LO $kubectl_url
    curl -s -L $helm_url -o helm.tar.gz
    curl -s -L $aws_iam_authenticator_url -o aws-iam-authenticator
    curl -s -L $kubelogin_url -o kubelogin.zip

    # unzip
    tar -xf kconnect.tar.gz
    tar -xf helm.tar.gz
    mv linux-*/helm .
    unzip -qq kubelogin.zip
    mv bin/linux_amd64/kubelogin .

    # cleanup
    rm -f kconnect.tar.gz
    rm -f helm.tar.gz
    rm -rf linux-*
    rm -f kubelogin.zip
    rm -rf bin

    # permissions
    chmod +x kubectl
    chmod +x aws-iam-authenticator
    chmod +x kubelogin

elif [[ "$OSTYPE" == "darwin"* ]]; then
    
    # Mac OSX
    kconnect_url=$(echo "https://github.com/fidelity/kconnect/releases/download/TAG/kconnect_macos_amd64.tar.gz" | sed "s/TAG/$latest_kconnect_release_tag/" )
    kubectl_url=$(echo "https://dl.k8s.io/release/TAG/bin/darwin/amd64/kubectl" | sed "s/TAG/$latest_kubectl_release_tag/" )
    helm_url=$(echo "https://get.helm.sh/helm-TAG-darwin-amd64.tar.gz" | sed "s/TAG/$latest_helm_release_tag/" )
    aws_iam_authenticator_url=$(echo "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/vTAG/aws-iam-authenticator_TAG_darwin_amd64" | sed "s/TAG/$aws_iam_authenticator_release_tag/g" )
    kubelogin_url=$(echo "https://github.com/Azure/kubelogin/releases/download/TAG/kubelogin-darwin-amd64.zip" | sed "s/TAG/$latest_kubelogin_release_tag/")
    
    echo "kconnect url: $kconnect_url" 
    echo "kubectl url: $kubectl_url"
    echo "helm url: $helm_url"
    echo "aws_iam_authenticator url: $aws_iam_authenticator_url"
    echo "kubelogin url: $kubelogin_url"

    # download 
    curl -s -L $kconnect_url -o kconnect.tar.gz
    curl -s -LO $kubectl_url
    curl -s -L $helm_url -o helm.tar.gz
    curl -s -L $aws_iam_authenticator_url -o aws-iam-authenticator
    curl -s -L $kubelogin_url -o kubelogin.zip

    # unzip
    tar -xf kconnect.tar.gz
    tar -xf helm.tar.gz
    mv darwin-*/helm .
    unzip -qq kubelogin.zip
    mv bin/darwin_amd64/kubelogin .

    # cleanup
    rm -f kconnect.tar.gz
    rm -f helm.tar.gz
    rm -rf darwin-*
    rm -f kubelogin.zip
    rm -rf bin

    # permissions
    chmod +x kubectl
    chmod +x aws-iam-authenticator
    chmod +x kubelogin

elif [[ "$OSTYPE" == "msys" ]]; then
    # Win git bash
   
    kconnect_url=$(echo "https://github.com/fidelity/kconnect/releases/download/TAG/kconnect_windows_amd64.zip" | sed "s/TAG/$latest_kconnect_release_tag/" )
    kubectl_url=$(echo "https://dl.k8s.io/release/TAG/bin/windows/amd64/kubectl.exe" | sed "s/TAG/$latest_kubectl_release_tag/" )
    helm_url=$(echo "https://get.helm.sh/helm-TAG-windows-amd64.zip" | sed "s/TAG/$latest_helm_release_tag/" )
    aws_iam_authenticator_url=$(echo "https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/vTAG/aws-iam-authenticator_TAG_windows_amd64.exe" | sed "s/TAG/$aws_iam_authenticator_release_tag/g" )
    kubelogin_url=$(echo "https://github.com/Azure/kubelogin/releases/download/TAG/kubelogin-win-amd64.zip" | sed "s/TAG/$latest_kubelogin_release_tag/")
    
    echo "kconnect url: $kconnect_url" 
    echo "kubectl url: $kubectl_url"
    echo "helm url: $helm_url"
    echo "aws_iam_authenticator url: $aws_iam_authenticator_url"
    echo "kubelogin url: $kubelogin_url"

    # download 
    curl -k -s -L $kconnect_url -o kconnect.zip
    curl -k -s -LO $kubectl_url
    curl -k -s -L $helm_url -o helm.zip
    curl -k -s -L $aws_iam_authenticator_url -o aws-iam-authenticator.exe
    curl -k -s -L $kubelogin_url -o kubelogin.zip

    # unzip
    unzip -qq kconnect.zip
    unzip -qq helm.zip
    mv windows-amd64/helm.exe .
    unzip -qq kubelogin.zip
    mv bin/windows_amd64/kubelogin.exe .

    # cleanup
    rm -f kconnect.zip
    rm -f helm.zip
    rm -rf windows-amd64
    rm -f kubelogin.zip
    rm -rf bin

fi
