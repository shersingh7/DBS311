//NAME: Davinder Verma
//ID: 121802201
//EMAIL: dverma22@myseneca.ca
#define _CRT_SECURE_NO_WARNINGS
#include <iostream>
#include <cstring>
#include <iomanip>
#include <string>
#include <occi.h>
#define MAX_ARRAY_SIZE 5

using oracle::occi::Environment;
using oracle::occi::Connection;
using namespace oracle::occi;


//shopping cart
struct ShoppingCart
{
    int product_id;
    double price;
    int quantity;

};
//C++ functions
int mainMenu();
int customerLogin(Connection* conn, int customerId);
int addToCart(Connection* conn, struct ShoppingCart* cart);
double findProduct(Connection* conn, int product_id);
void displayProducts(struct ShoppingCart* cart, int productCount);
int checkout(Connection* conn, struct ShoppingCart* cart, int customerId, int productCount);
//SQL procedures
bool find_customerSQL(Connection* conn, int customerId, int& found);
bool find_productSQL(Connection* conn, int product_id, double& price);
void add_order(Connection* conn, int customer_id, int& newOrderID);
void add_orderline(Connection* conn, int orderId, int itemId, int productId, int quantity, double price);
//custom functions
int getInt();
int getIntInRange(int min, int max);
int main(void) {
    //enviroment and connection variables
    Environment* env = nullptr;
    Connection* conn = nullptr;


    // login
    std::string usr = "dbs311_211b28"; // Oracle username found in grade
    // password
    std::string pass = "31185170"; // Oracle username found in grade
    // connection
    std::string srv = "myoracle12c.senecacollege.ca:1521/oracle12c/";

    //allocate memory for an array of ShoppingCart type
    ShoppingCart shoppingCart[MAX_ARRAY_SIZE];
    int scCounter = 0;
    try {
        env = Environment::createEnvironment(Environment::DEFAULT);
        //creating connection
        conn = env->createConnection(usr, pass, srv);
        // creating environment
        Statement* stmt = conn->createStatement();

        int selectedOption = 1;
        while (selectedOption)
        {
            selectedOption = mainMenu();
            if (selectedOption)
            {
                int customerId = 0;
                std::cout << "Enter the customer ID: ";
                customerId = getInt();

                if (customerLogin(conn, customerId))
                {
                    //populate the array of Shopping carts
                    scCounter = addToCart(conn, shoppingCart);

                    //display entered products
                    displayProducts(shoppingCart, scCounter);

                    //check out
                    checkout(conn, shoppingCart, customerId, scCounter);

                    conn->terminateStatement(stmt);

                }
                else
                    std::cout << "The customer does not exist.\n";

            }
        }
        std::cout << "Good bye!...\n";


        env->terminateConnection(conn);
        Environment::terminateEnvironment(env);

    }
    //catch errors
    catch (SQLException& sqlExcp) {
        std::cout << sqlExcp.getErrorCode() << ": " << sqlExcp.getMessage();
        std::cout << sqlExcp.getErrorCode() << ": " << sqlExcp.getMessage();
    }
    return 0;
}

int mainMenu()
{
    int  found = 0;

    std::cout << "*************Main Menu by Student ********************\n"
        << "1)" << std::setw(13) << "Login\n"
        << "0)" << std::setw(12) << "Exit\n"
        << "Enter an option (0-1): ";
    found = getIntInRange(0, 1);

    return found;
}

int customerLogin(Connection* conn, int customerId)
{
    int found = 0;
    find_customerSQL(conn, customerId, found);
    return found;
}

int addToCart(Connection* conn, ShoppingCart* cart)
{
    int counter = 0, option = 1;
    std::cout << "--------------Add Products to Cart--------------\n";
    while (option && counter <= 5)
    {
        int product_id = 0;
        double price = 0;
        std::cout << "Enter the product ID: ";
        product_id = getInt();
        price = findProduct(conn, product_id);
        if (price > 0)
        {

            std::cout << "Enter the product Quantity: ";
            int quantity = getInt();
            //populate the array
            cart[counter].price = price;
            cart[counter].quantity = quantity;
            cart[counter].product_id = product_id;
            counter++;
            std::cout << "Enter 1 to add more products or 0 to checkout: ";
            option = getIntInRange(0, 1);
        }
        else if (price == 0)
        {
            std::cout << "The product does not exist. Try again..." << std::endl;
        }
    }
    return counter;
}

double findProduct(Connection* conn, int product_id)
{
    double price = 0;

    return find_productSQL(conn, product_id, price) ? price : -1;
}

void displayProducts(ShoppingCart* cart, int productCount)
{
    double total = 0.0;
    std::cout << "------- Ordered Products ---------\n";
    for (auto i = 0; i < productCount; i++)
    {
        std::cout << "---Item " << i + 1 << std::endl
            << "Product ID: " << cart[i].product_id << std::endl
            << "Price: " << cart[i].price << std::endl
            << "Quantity: " << cart[i].quantity << std::endl;
        total += cart[i].price * cart[i].quantity;
    }
    std::cout << "----------------------------------\n";
    std::cout << " Total: " << total << std::endl;


}

int checkout(Connection* conn, ShoppingCart* cart, int customerId, int productCount)
{
    std::string option{};

    while (!(option == "N" || option == "n" || option == "Y" || option == "y"))
    {
        std::cout << "Would you like to checkout? (Y/y or N/n) ";
        std::cin >> option;
        if (!(option == "N" || option == "n" || option == "Y" || option == "y"))
            std::cout << "You entered wrong value\n";
    }
    int newOrderId = 0;
    if (option == "y" || option == "Y") {
        for (auto i = 0; i < productCount; i++)
        {
            add_order(conn, customerId, newOrderId);
            add_orderline(conn, newOrderId, i + 1, cart[i].product_id, cart[i].quantity, cart[i].price);

        }
        std::cout << "The order is successfully comleted" << std::endl;
    }
    else
        std::cout << "The order is cancelled.\n";
    return (option == "y" || option == "Y" ? 1 : 0);
}

bool find_customerSQL(Connection* conn, int customerId, int& found)
{
    //create connection
    Statement* stmt = conn->createStatement();
    //call the find_customer procedure from the DBS
    stmt->setSQL("BEGIN find_customer(:1, :2); END;");

    //set the first parameterf
    stmt->setInt(1, customerId);
    //set the second parameter
    stmt->registerOutParam(2, Type::OCCIINT, sizeof(found));
    //call the procedure
    stmt->executeUpdate();
    // get the value of the second (OUT) parameter
    found = stmt->getInt(2);

    //close the connection
    conn->terminateStatement(stmt);

    return found;
}

bool find_productSQL(Connection* conn, int product_id, double& price)
{
    //create connection
    Statement* stmt = conn->createStatement();
    //call the find_product procedure from the DBS
    stmt->setSQL("BEGIN find_product(:1, :2); END;");
    //set the first parameter
    stmt->setInt(1, product_id);
    //set the second parameter
    stmt->registerOutParam(2, Type::OCCINUMBER, sizeof(price));
    //call the procedure
    stmt->executeUpdate();
    //get the value of the second (OUT) parameter
    price = stmt->getNumber(2);

    //close the connection
    conn->terminateStatement(stmt);
    return (price > 0);
}

void add_order(Connection* conn, int customer_id, int& newOrderID)
{
    //create connection
    Statement* stmt = conn->createStatement();
    //call the add_order procedure from the DBS
    stmt->setSQL("BEGIN add_order(:1, :2); END;");
    //set the first parameter
    stmt->setInt(1, customer_id);
    //set the second parameter
    stmt->registerOutParam(2, Type::OCCIINT, sizeof(newOrderID));
    //call the procedure
    stmt->executeUpdate();
    //get the value of the second (OUT) parameter
    newOrderID = stmt->getInt(2);

    //close the connection
    conn->terminateStatement(stmt);
}

void add_orderline(Connection* conn, int orderId, int itemId, int productId, int quantity, double price)
{
    //Create connection
    Statement* stmt = conn->createStatement();
    //call the add_orderLine procedure from the DBS
    stmt->setSQL("BEGIN add_orderLine(:1, :2, :3, :4, :5); END;");
    //set the first parameter
    stmt->setInt(1, orderId);
    //set the second parameter
    stmt->setInt(2, itemId);
    //set the third parameter
    stmt->setInt(3, productId);
    //set the fourth parameter
    stmt->setInt(4, quantity);
    //set the fifth parameter
    stmt->setDouble(5, price);
    //call the procedure
    stmt->executeUpdate();

    //close the connection
    conn->terminateStatement(stmt);

}
//custom functions to check the user inputs 
int getInt(void)
{
    char NL = 'x';
    int Value = 0;
    while (NL != '\n')
    {
        scanf("%d%c", &Value, &NL);
        if (NL != '\n')
        {
            while (getchar() != '\n');
            std::cout << "*************Main Menu by Student ********************\n"
                << "1)" << std::setw(13) << "Login\n"
                << "0)" << std::setw(12) << "Exit\n";
            printf("You entered a wrong value. Enter an option (0-1): ");
        }

    }
    return Value;
}

//get an integer value in range between min and max
int getIntInRange(int min, int max)
{
    int value = 0;
    do
    {

        value = getInt();
        if (value > max || value < min)
        {
            std::cout << "*************Main Menu by Student ********************\n"
                << "1)" << std::setw(13) << "Login\n"
                << "0)" << std::setw(12) << "Exit\n";
            printf("You entered a wrong value. Enter an option (%d-%d): ", min, max);
        }
    } while (value > max || value < min);
    return value;
}
