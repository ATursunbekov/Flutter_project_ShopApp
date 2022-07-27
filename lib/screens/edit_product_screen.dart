import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/widgets/my_button.dart';
import 'package:shop_app/widgets/simple_button.dart';

import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {

  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(id: '', title: '', description: '', price: 0, imageUrl: '');
  var isInit = true;
  var _initVal = {
    'title' : '',
    'description' : '',
    'price' : '',
    'imageUrl' : '',
  };
  var isLoading= false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    if (isInit)
      {
        isInit = false;
        final productId = ModalRoute.of(context)!.settings.arguments;
        if (productId != null)
          {
            _editedProduct =  Provider.of<Products>(context, listen: false).findById(productId as String);
            _initVal = {
              'title' : _editedProduct.title,
              'description' : _editedProduct.description,
              'price' : _editedProduct.price.toString(),
              //'imageUrl' : _editedProduct.imageUrl,
              'imageUrl' : '',
            };
            _imageUrlController.text = _editedProduct.imageUrl;
          }
      }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
  }

  void _updateImageUrl()
  {

    if(!_imageUrlFocusNode.hasFocus)
      {
  //       if (!_imageUrlController.text.isEmpty || (!_imageUrlController.text.startsWith('http') &&
  //           !_imageUrlController.text.startsWith('https')) || (!_imageUrlController.text.endsWith('.png') &&
  //           !_imageUrlController.text.endsWith('.jpg') && !_imageUrlController.text.endsWith('.jpeg'))){
  //         return;
  // }
        setState(() {});
      }
  }

  Future<void> _saveForm() async
  {
    setState(() {
      isLoading = true;
    });
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    if (_editedProduct.id != '')
      {
        await Provider.of<Products>(context, listen: false).updateProduct(_editedProduct.id, _editedProduct);
      } else {
      try{
        await Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
      } catch (err) {
        await showDialog(context: context, builder: (ctx) =>
            AlertDialog(
              title: Text('An error occured!'),
              content: Text('Something went wrong!'),
              actions: [
                SimpleButton('Ok', () {
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.of(ctx).pop();
                })
              ],
            ));
      }
      }
    Navigator.of(context).pop();
    setState(() {
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(onPressed: (){
            _saveForm();
          }, icon: Icon(Icons.save)),

        ],
      ),
      body: isLoading ? Center(
        child: CircularProgressIndicator(),
      ) :Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(decoration: InputDecoration(labelText: 'Title'),
                initialValue: _initVal['title'],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(_priceFocusNode);
                },
                onSaved: (val){
                _editedProduct =  Product(id: _editedProduct.id,
                    isFavorite: _editedProduct.isFavorite,
                    title: val!,
                    description: _editedProduct.description,
                    price: _editedProduct.price,
                    imageUrl: _editedProduct.imageUrl);
                },
                validator: (val) {
                if(val!.isEmpty)
                  {
                    return 'Please provide title';
                  }
                return null;
                },
              ),
              TextFormField(decoration: InputDecoration(labelText: 'Price'),
                initialValue: _initVal['price'],
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                focusNode: _priceFocusNode,
                onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_descriptionFocusNode);
                },
                onSaved: (val){
                  _editedProduct =  Product(id: _editedProduct.id,
                      isFavorite: _editedProduct.isFavorite,
                      title: _editedProduct.title,
                      description: _editedProduct.description,
                      price: double.parse(val!),
                      imageUrl: _editedProduct.imageUrl);
                },
                validator: (val)
                {
                  if (val!.isEmpty)
                    {
                      return 'Please enter the price';
                    }
                  if (double.tryParse(val) == null)
                    {
                      return 'Please enter valid number.';
                    }
                  if (double.parse(val)  <= 0)
                    {
                      return 'Please enter number greater than 0';
                    }
                  return null;
                },
              ),
              TextFormField(decoration: InputDecoration(labelText: 'Description'),
                initialValue: _initVal['description'],
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                focusNode: _descriptionFocusNode,
                onSaved: (val){
                  _editedProduct =  Product(id: _editedProduct.id,
                      isFavorite: _editedProduct.isFavorite,
                      title: _editedProduct.title,
                      description: val!,
                      price: _editedProduct.price,
                      imageUrl: _editedProduct.imageUrl);
                },
                validator: (val)
                {
                  if (val!.isEmpty)
                    {
                      return 'Please enter description';
                    }
                  if(val.length <= 10)
                    {
                      return 'Should be at least 10 characters long';
                    }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: EdgeInsets.only(top: 8, right: 10),
                    decoration: BoxDecoration(
                      border:Border.all(width: 1, color: Colors.grey),
                    ),
                    child: _imageUrlController.text.isEmpty ? Text('Enter URL') : FittedBox(
                      child: Image.network(_imageUrlController.text, fit: BoxFit.cover,),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Image URL',
                      ),
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      controller: _imageUrlController,
                      focusNode: _imageUrlFocusNode,
                      onEditingComplete: () {
                        setState(() {});
                      },
                      onFieldSubmitted: (_) {
                        _saveForm();
                      },
                      onSaved:  (val){
                        _editedProduct =  Product(id: _editedProduct.id,
                            isFavorite: _editedProduct.isFavorite,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: val!);
                      },
                      validator: (val)
                      {
                        if (val!.isEmpty)
                          {
                            return 'Please enter an Image URL';
                          }
                        // if (!val.startsWith('http') && !val.startsWith('https'))
                        //   {
                        //     return'Please enter valid URL';
                        //   }
                        // if (!val.endsWith('.png') && !val.endsWith('.jpg') && !val.endsWith('.jpeg'))
                        //   {
                        //     return 'Please enter valid image URL';
                        //   }
                        return null;
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
