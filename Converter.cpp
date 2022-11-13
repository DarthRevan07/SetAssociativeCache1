#include<bits/stdc++.h>
using namespace std;

const int dataSize = 14;

long long hexadecimalToDecimal(string s)
{
    long long len = s.size();
    long long n=0;
    long long base=1;
    for(long long i=len-1;i>=0;i--){
       char c=s[i];
       if(c>='0' and c<='9'){
         n+=(c-'0')*base;
       }
       else{
         n+=(c-'a'+10)*base;

       }
       base*=16;
       
    }
    return n;
    
}

string decimaltoBinary(long long n){
    string s="";
    long long x=1;
    while(x<=n){
        x*=2;

    }
    x/=2;
    while(x>=1){
        if(x<=n){
            n-=x;
            s+="1";

        }
        else{
            s+="0";
        }
        x/=2;
    }
    return s;
}





int main() {

    string str;
    ifstream MyReadFile("doc3.txt");
    ofstream MyFile("res3.txt");
    while (getline (MyReadFile, str)) {
        string substr=str.substr(1);
        long long n=hexadecimalToDecimal(substr);
        string binary=decimaltoBinary(n);
        long long sz=binary.size();
        while(sz<28){
            binary='0'+binary;
            sz++;
        }
        long long x=rand() % (10001);
        string bin=decimaltoBinary(x);
        long long size=bin.size();
        while(size<dataSize){
           bin='0'+bin;
           size++;
        }

        int readWrite = rand() % (2);
        MyFile<<binary<<bin<<readWrite<<endl;
    }
    
    
    MyReadFile.close();
    MyFile.close();
    return 0;
}