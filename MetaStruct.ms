--fileins
(
	local thisdir = (getFilenamePath(getThisScriptFilename()))
	filein (thisdir + @"lib/models.ms")
)


-- StructGenerator Variable def
struct MetaStructVar (
	id         = undefined,
	value      = undefined,
	type       = undefined
)
struct MetaStructFunc (
	id   = undefined,
	code = undefined
)



--MetaStruct
struct MetaStruct (

	-- Public vars
	struct_name,
	struct_variables = #(),
	struct_functions = #(),

	-- Struct options
	isSkeleton,

	-- lexical stuff is public
	_p_space            = " ",
	_p_new_line         = "\n",
	_p_comma            = ",",
	_p_struct_keyw      = "struct",
	_p_open_parenthese  = "(",
	_p_close_parenthese = ")",
	_p_comma_nl         = this._p_comma + this._p_new_line,


	-- Private zone
	private


	-- the structure definition
	struct_def,


	fn _addToCode c indentation:"" = (
		local indent = ""
		if (superclassof indentation) == Number then (for i=1 to indentation do (indent = indent + "\t"))
		this.struct_def = this.struct_def + indent + c
	),
	fn _addSpace               indentation:undefined = (_addToCode _p_space             indentation:indentation),
	fn _addNewLine             indentation:undefined = (_addToCode _p_new_line          indentation:indentation),
	fn _addComponentDefReturn  indentation:undefined = (_addToCode _p_comma_nl          indentation:indentation),
	fn _addStructKeyword       indentation:undefined = (_addToCode (_p_struct_keyw + _p_space) indentation:indentation),
	fn _openParenthesis        indentation:undefined = (_addToCode _p_open_parenthese   indentation:indentation),
	fn _closeParenthesis       indentation:undefined = (_addToCode _p_close_parenthese  indentation:indentation),
	fn __addVariable v = (
		this._addToCode ((v.id as string) + " = undefined") indentation:1
		this._addComponentDefReturn()
	),
	fn __addFunction f = (
		this._addToCode f.code  indentation:1
		this._addComponentDefReturn()
	),
	fn __addVarInitCode v = (if v.value != undefined then (this._addToCode ("this." + (v.id as string) + " = " + v.value + "\n")  indentation:2)),
	fn _defStructIntro     = (
		this.struct_def = ""
		this._addStructKeyword()           -- struct
		this._addToCode (this.struct_name) -- name
		this._addSpace()
		this._openParenthesis()          -- (
		this._addNewLine()
	),
	fn _defStructEnd = (this._addNewLine();this._closeParenthesis()),
	fn _defStructVariables = (for v in this.struct_variables where (isKindOf v MetaStructVar) do (this.__addVariable v)),
	fn _defStructFunctions = (for f in this.struct_functions where (isKindOf f MetaStructFunc) do (this.__addFunction f)),
	fn _defConstructor = (
		_addToCode ("on " + this.struct_name + " create do ( \n")  indentation:1
		(for v in this.struct_variables where (isKindOf v MetaStructVar) do (this.__addVarInitCode v))
		_addToCode "\n\t)"
		_addNewLine
	),
	



	public
	-- Public from here
	fn generateStructCode = (
		_defStructIntro()

		_addToCode "\n\t/*----------Variables----------*/\n"
		_defStructVariables()

		_addToCode "\n\t/*----------Methods----------*/\n"
		_defStructFunctions()

		_addToCode "\n\t/*----------Constructor----------*/\n"

		_defConstructor()
		_defStructEnd()

		if isSkeleton == true then (
			_addNewLine()
			_addToCode ("global " + this.struct_name + " = " + this.struct_name + "()")
		)
	),


	fn getDef = (this.struct_def),

	on create do ()
)


/*mmsg = MetaStruct \
		struct_name:"msgenareted" \
		struct_variables:#(
			(MetaStructVar id:#va value:"99"       type:#integer)
		) \
		struct_functions:#(
			(MetaStructFunc id:#sayHello code:"fn sayHello = (print \"Helloworld!\")")
		) \
		isSkeleton:false

mmsg.generateStructCode()
x = execute mmsg.struct_def*/


-- Define object options
obj_meta_name = "ObjName"
obj_meta_variables = #(
	(MetaStructVar id:#myInt value:"99" type:#integer),
	(MetaStructVar id:#myFloat value:"55.5" type:#float)
)

-- Instance a metastruct
obj_meta = MetaStruct struct_name:"ObjName" struct_variables:obj_meta_variables


-- generate struct code
obj_meta.generateStructCode()
print (obj_meta.getDef())

0