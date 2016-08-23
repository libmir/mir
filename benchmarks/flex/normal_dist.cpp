#include <iostream>
#include <random>
#include <cmath>
int main()
{
    std::random_device rd;
    std::mt19937 gen(rd());

    std::normal_distribution<> d(0);
    int n = pow(10, 7);

    double c;
    for(int i=0; i<n; ++i) {
        c = d(gen);
    }
    std::cout << c;
}
