import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PayfareDialog extends StatefulWidget {
  const PayfareDialog({
    super.key,
    required this.fareAmount,
  });
  final double fareAmount;

  @override
  State<PayfareDialog> createState() => _PayfareDialogState();
}

class _PayfareDialogState extends State<PayfareDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.red,
      child: Container(
        margin: EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text("Fare Amount".toUpperCase()),
            SizedBox(
              height: 20,
            ),
            Divider(
              thickness: 2,
              color: Colors.purple,
            ),
            SizedBox(
              height: 10,
            ),
            Text("Rupe symbol ${widget.fareAmount.toString()}"),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "This is the total fare Amount. Please pay it to the driver",
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  Future.delayed(Duration(milliseconds: 10000),(){
                    Get.back(result: "Cash Paid");
                    Get.offAllNamed("/home");
                  });
                },
                child: Row(
                  children: [
                    Text("Pay Cash "),
                     Text("Rupe symbol ${widget.fareAmount.toString()}"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
