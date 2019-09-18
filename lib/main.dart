import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Provider Explained

/// ******* SAMPLE CODE ONLY FOR EXPLANATIONS, THIS CODE WILL NOT RUN *******

/// 1) Put your Model/BLoC/whatever in another file.
/// It's just here for convenience.
/// We're using ChangeNotifier here but you can also use
/// ValueNotifier, or make up your own. It's usually easier
/// to use these, though. We have two of these to  help demonstrate
/// ProxyProvider, down below.
class ChangeNotifierModel extends ChangeNotifier {
  String stringThatChanges = 'testing';

  void changeTheString(String input) {
    stringThatChanges = input;

    /// Ensure you notify listeners as the last
    /// thing you do in any function that changes a value.
    notifyListeners();
  }
}
/// OR
class ValueNotifierModel extends ValueNotifier {
  String stringThatChanges = 'testing';

  ValueNotifierModel(value) : super(value);

  void changeTheString(String input) {
    stringThatChanges = input;

    /// Ensure you notify listeners as the last
    /// thing you do in any function that changes a value.
    notifyListeners();
  }
}

void main() {
  runApp(LotsOfStuffThatDoesNotNeedMyModelObject());
}

class LotsOfStuffThatDoesNotNeedMyModelObject extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// Anything in here is higher than the lowest place you can put your
    /// Provider and still be able to use it.
    ///
    /// *** If two branches both need access to MyModelObject then consider
    /// using one Provider in each branch, placed down low, rather than pollute
    /// the scope of both branches by putting one Provider high up in the tree
    /// You can have an unlimited number of Providers returning
    /// the same type, so you can have them in different branches.
    ///
    /// Here we put a bunch of junk in between the top of the tree and the Provider
    /// just to give you the general idea of what we mean when we say to put the
    /// Provider as low in the tree as you can.
    return Container(
      child: SizedBox(
        child: Container(
          child: SizedBox(
            child: Container(
              child: ProviderIsInHere(),
            )),
        ),
      ),
    );
  }
}

///**************************************************************************
/// 2) The Provider(s)
/// ///**************************************************************************

/// Put this as low in the tree as you can to avoid polluting the scope, but
/// you have to have a build method between it and the Consumer because you
/// need to create a new Context that includes the Provider before you can
/// use it to access MyModelObject. To ensure you have a build method,
/// and keep the Provider as far down the tree as you can, just
/// make the child of the Provider call the constructor of another class
/// that has its own build method. Then put the consumer in that tree.

class ProviderIsInHere extends StatefulWidget {
  @override
  _ProviderIsInHereState createState() => _ProviderIsInHereState();
}

class _ProviderIsInHereState extends State<ProviderIsInHere> {
  ValueNotifierModel _valueNotifierModelInstance;

  void initState() {
    super.initState();
    _valueNotifierModelInstance = ValueNotifierModel(ValueNotifierModel);
  }

  void updateObject() {
    setState(() {
      _valueNotifierModelInstance = ValueNotifierModel(ValueNotifierModel);
    });
  }

  @override
  Widget build(BuildContext context) {
    /// You can use just one of the many Provider classes by itself, and make its
    /// child be the rest of your tree.
    return Provider<ChangeNotifierModel>(
      builder: (BuildContext context) => ChangeNotifierModel(),

      /// DO NOT use both the single Provider above and the MultiProvider below
      /// in production code, this is only here to show you how to use
      /// a MultiProvider. You would use this *instead of* a single Provider if you
      /// have more than one. You *could* use separate, nested Providers, but
      /// MultiProvider was created to make your life easier in this situation.
      /// You may as well take advantage of it.
      child: MultiProvider(
        providers: [

          /// These are other Providers you can use, instead of the regular Provider:
          ChangeNotifierProvider<ChangeNotifierModel>(
            builder: (BuildContext context) => ChangeNotifierModel(),
          ),
          ValueListenableProvider<ValueNotifierModel>.value(
            value: _valueNotifierModelInstance.value,
          ),

          /// Others include:
          ///   FutureProvider
          ///   StreamProvider
          ///   ListenableProvider
          ///   InheritedProvider
        ],

        /// We need another build method to create a new context before we can use the
        /// Providers we created above. We get it by making the child a different class,
        /// with its own build method.
        child: UseTheProvidersInThisWidget(),
      ),
    );
  }
}

///**************************************************************************
/// 3) Consuming (using) it
///**************************************************************************

class UseTheProvidersInThisWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// Approach 1 of 3) Make an instance of MyModelObject above the return and use it below in 1A
    final providerOfAccessedObject = Provider.of<ChangeNotifierModel>(context);

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            /// 1A) This is where we're reusing the above variable
            providerOfAccessedObject.stringThatChanges,
          ),
          Text(
            /// Approach 2 of 3) Just call Provider.of where you use it, like this.
            Provider.of<ChangeNotifierModel>(context).stringThatChanges,
          ),

          /// Approach 3 of 3) Use a Consumer that is higher up in the tree than where you use it.
          /// It's preferable to put this as far down the tree as you can, but the made-up name
          /// for your instance will be available anywhere after the return.
          Consumer<ChangeNotifierModel>(
            builder: (context, madeUpNameForObjectInstance, child) {
              return Text(
                'The value of MyObject.stringThatChanges is ${madeUpNameForObjectInstance.stringThatChanges}');
            },
          )
        ],
      ),
    );
  }
}
