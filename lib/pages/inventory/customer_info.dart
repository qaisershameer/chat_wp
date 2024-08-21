import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_wp/services/auth/auth_service.dart';
import 'package:chat_wp/services/accounts/account_service.dart';
import 'package:chat_wp/pages/inventory/customer_add.dart';

// will delete after correcting form edit delete
import 'package:chat_wp/services/accounts/customer_service.dart';

class CustomerInfo extends StatefulWidget {
  const CustomerInfo({super.key});

  @override
  State<CustomerInfo> createState() => _CustomerInfoState();
}

class _CustomerInfoState extends State<CustomerInfo> {

  // auth account services
  final AuthService _authService = AuthService();
  final AccountService _accountService = AccountService();
  final CustomerService _customerService = CustomerService();

  // text controller
  final TextEditingController _textCustomer = TextEditingController();


  // open a dialogue box to add customer
  void openCustomerBox(String? docID, String? customerText, String userId) {
    _textCustomer.text = customerText ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _textCustomer,
        ),
        actions: [
          // button to save Customers
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                // add a customer to database
                _customerService.addCustomer(_textCustomer.text, userId);
              } else {
                // update customer to database
                _customerService.updateCustomer(docID, _textCustomer.text, userId);
              }

              // clear the text controller after adding into database
              _textCustomer.clear();

              // close to dialogue box
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // open a dialogue box to delete customer
  void _deleteCustomerBox(BuildContext context, String docID) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Customer'),
          content: const Text('Are you sure! want to Delete this Customer?'),
          actions: [
            // cancel button
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),

            // delete button
            TextButton(
                onPressed: () {
                  _customerService.deleteCustomer(docID);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Customer deleted!'),
                    ),
                  );
                },
                child: const Text('Delete')),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    // GET CURRENT USER ID
    String userId = _authService.getCurrentUser()!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        // centerTitle: true,
        // backgroundColor: Colors.transparent,
        foregroundColor: Colors.teal,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0, bottom: 16.0),
            // Add button
            child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 10.0,),
                child: IconButton(
                    // onPressed: () => openCustomerBox(null, '', userId),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const CustomerAdd()));
                    } ,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ))),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // stream: _accountService.getAccountsTypeStream(userId, 'CUSTOMER'),
        stream: _accountService.getAccountsTypeStream(userId, 'PARTIES'),
        builder: (context, snapshot) {
          // if we have data, get all the docs.
          if (snapshot.hasData) {
            List customerList = snapshot.data!.docs;

            // display as a list
            return ListView.builder(
                itemCount: customerList.length,
                itemBuilder: (context, index) {
                  // get each individual doc
                  DocumentSnapshot document = customerList[index];
                  // String docID = document.id;

                  // get customer from each doc
                  Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

                  String customerText = data['accountName'];
                  String phoneText = data['phone'];
                  String emailText = data['email'];

                  // Timestamp timeStamp = data['timestamp'] as Timestamp;
                  // DateTime date = timeStamp.toDate();
                  // String formatedDT = DateFormat('dd MMM yyyy hh:mm:ss a').format(date);

                  // display as a list title
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin:
                    const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                    padding: const EdgeInsets.all(3),
                    child: ListTile(
                      title: Text(customerText),
                      subtitle: Text('$phoneText\n$emailText'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // update button
                          IconButton(
                            onPressed: (){},
                            // onPressed: () =>
                            //     openCustomerBox(docID, customerText, userId),
                            icon: const Icon(Icons.settings),
                          ),
                          // delete button
                          IconButton(
                            onPressed: (){},
                            // onPressed: () =>
                            //     _deleteCustomerBox(context, docID),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          } else {
            return const Center(child: Text('no customer data to display!'));
          }
        },
      ),
    );
  }

}