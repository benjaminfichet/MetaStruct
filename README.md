# MetaStruct
A Maxscript Structure generator. Merely a proof of concept, need correct implementation
Used to build struct definitions on the fly, an exemple use would be *an object to entry xml mapper*. Building up objects from xml tags.

```maxscript
-- Define some variables
obj_meta_variables = #(   
	(MetaStructVar id:#myInt value:"99" type:#integer),
	(MetaStructVar id:#myFloat value:"55.5" type:#float)
)

-- Instance a metastruct
obj_meta = MetaStruct struct_name:"ObjName" struct_variables:obj_meta_variables

-- generate struct code
obj_meta.generateStructCode()

-- Get it
obj_meta.getStructDef()
```

The previous snippet would produce the following as string : 
```maxscript
struct ObjName (
	private

	/*----------Variables----------*/
	myInt = undefined,
	myFloat = undefined,

	public
	/*----------Accessors----------*/
	fn set_myInt v = (this.myInt = (v as Integer)),
	fn get_myInt = (this.myInt),

	fn set_myFloat v = (this.myFloat = (v as Float)),
	fn get_myFloat = (this.myFloat),


	/*----------Methods----------*/

	/*----------Constructor----------*/
	on create do ( 
		this.myInt = set_myInt 99
		this.myFloat = set_myFloat 55.5

	)
)
```
