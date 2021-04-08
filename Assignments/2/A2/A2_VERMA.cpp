//NAME: Davinder Verma
//ID: 121802201
//EMAIL: dverma22@myseneca.ca

#include"A2_VERMA.h"

int main() {
	Environment* env = nullptr;
	Connection* conn = nullptr;

	string user = "dbs311_211b28";
	string pass = "31185170";
	string constr = "myoracle12c.senecacollege.ca:1521/oracle12c";

	try {
		env = Environment::createEnvironment(Environment::DEFAULT);
		conn = env->createConnection(user, pass, constr);
		cout << "Connection is successful!" << endl;

		int option = -1, count = -1, cust_no = -1;
		while (option != 0) 
		{
			option = mainMenu();

			if (option == 1)
			{
				cout << "Enter the customer ID: ";
				cin >> cust_no;

				if (customerLogin(conn, cust_no) == 0) 
				{
					cout << "The customer does not exist." << endl;
				}
				else
				{
					ShoppingCart cart[5];
					count = addToCart(conn, cart);
					displayProducts(cart, count);
					checkout(conn, cart, cust_no, count);
				}

			}
		}

		cout << "Bye!..." << endl;

		env->terminateConnection(conn);
		Environment::terminateEnvironment(env);
	}
	catch (SQLException& sqlExcp) {
		cout << sqlExcp.getErrorCode() << ": " << sqlExcp.getMessage();
	}
	return 0;
}
