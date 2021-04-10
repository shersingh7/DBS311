#ifndef _SDDS_A2_VERMA_H
#define _SDDS_A2_VERMA_H

#include<iostream>
#include <occi.h>


using oracle::occi::Environment;
using oracle::occi::Connection;

using namespace oracle::occi;
using namespace std;

struct ShoppingCart
{
	int product_id;
	double price;
	int quantity;
};

int mainMenu()
{
	int option = 0;

	do 
	{
		cout << "******************** Main Menu by Verma ********************\n"
			<< "1)\tLogin\n"
			<< "0)\tExit\n";

		if (option != 0 && option != 1) 
		{
			cout << "Wrong value. Enter an option (0-1): ";
		}
		else cout << "Enter an option (0-1): ";

		cin >> option;

	} while (option != 0 && option != 1);

	return option;
}

int customerLogin(Connection* conn, int customerId)
{
	int found = 0;

	Statement* stmt = conn->createStatement();
	stmt->setSQL("BEGIN find_customer(:1, :2); END;");
	stmt->setInt(1, customerId);
	stmt->registerOutParam(2, Type::OCCIINT);
	stmt->executeUpdate();
	found = stmt->getInt(2);
	conn->terminateStatement(stmt);

	return found;
}

double findProduct(Connection* conn, int product_id)
{
	double price = 0;
	Statement* stmt = conn->createStatement();
	stmt->setSQL("BEGIN find_product(:1, :2); END;");
	stmt->setInt(1, product_id);
	stmt->registerOutParam(2, OCCIDOUBLE);
	stmt->executeUpdate();
	price = stmt->getDouble(2);
	conn->terminateStatement(stmt);

	return price;
}

int addToCart(Connection* conn, ShoppingCart cart[])
{
	ShoppingCart sCart;
	int i, id = -1, qty = -1, num = 0, option;
	cout << "-------------- Add Products to Cart --------------" << endl;

	for (i = 0; i < 5; i++) 
	{
		do 
		{
			cout << "Enter the product ID: ";
			cin >> id;

			if (findProduct(conn, id) == 0)
			{
				cout << "The product does not exist. Try again..." << endl;
			}

		} while (findProduct(conn, id) == 0);

		cout << "Product Price: " << findProduct(conn, id) << endl;
		cout << "Enter the quantity: ";
		cin >> qty;
		sCart.product_id = id;
		sCart.price = findProduct(conn, id);
		sCart.quantity = qty;
		cart[i] = sCart;

		if (i == 4) 
		{
			i = 5;
		}
		else 
		{
			do 
			{
				cout << "Enter 1 to add more products or 0 to checkout: ";
				cin >> option;
			} while (option != 0 && option != 1);
		}
		if (option == 0) 
		{
			i = 5;
		}
		num++;
	}
	return num;
}

void displayProducts(ShoppingCart cart[], int productCount) 
{
	double total = 0;
	cout << "------- Ordered Products ---------" << endl;

	for (size_t i = 0; i < productCount; ++i)
	{
		cout << "---Item " << i + 1 << endl;
		cout << "Product ID: " << cart[i].product_id << endl;
		cout << "Price: " << cart[i].price << endl;
		cout << "Quantity: " << cart[i].quantity << endl;
		total += (cart[i].price * cart[i].quantity);
	}

	cout << "----------------------------------\nTotal: " << total << endl;
}
int checkout(Connection* conn, ShoppingCart cart[], int customerId, int productCount) 
{
	int result = 0, newOrder = 0, i;
	char option = '\0';
	do 
	{
		cout << "Would you like to checkout ? (Y / y or N / n) ";
		cin >> option;

		if (option != 'Y' && option != 'y' && option != 'N' && option != 'n') 
		{
			cout << "Wrong input. Try again..." << endl;
		}

	} while (option != 'Y' && option != 'y' && option != 'N' && option != 'n');

	if (option == 'N' || option == 'n') 
	{
		cout << "The order is cancelled." << endl;
	}
	else 
	{
		Statement* stmt = conn->createStatement();
		stmt->setSQL("BEGIN add_order(:1, :2); END;");
		stmt->setInt(1, customerId);
		stmt->registerOutParam(2, Type::OCCIINT);
		stmt->executeUpdate();
		newOrder = stmt->getInt(2);

		for (i = 0; i < productCount; i++) 
		{
			stmt->setSQL("BEGIN add_orderline(:1, :2, :3, :4, :5); END;");
			stmt->setInt(1, newOrder);
			stmt->setInt(2, i + 1);
			stmt->setInt(3, cart[i].product_id);
			stmt->setInt(4, cart[i].quantity);
			stmt->setDouble(5, cart[i].price);
			stmt->executeUpdate();
		}

		cout << "The order is successfully completed." << endl;
		conn->terminateStatement(stmt);
		result = 1;
	}
	return result;
}

#endif // !_SDDS_A2_VERMA_H

