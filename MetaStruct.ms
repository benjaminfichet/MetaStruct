

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
	skeleton,

	-- Do we protect variables ? ie generating accessors
	protect_variables = true,

	-- lexical stuff is public
	_p_space            = " ",
	_p_new_line         = "\n",
	_p_comma            = ",",
	_p_struct_keyw      = "struct",
	_p_open_parenthese  = "(",
	_p_close_parenthese = ")",
	_p_comma_nl         = this._p_comma + this._p_new_line,


	-- Private bloc
	private


	-- the structure definition
	struct_def,

	fn _addSpace               indentation:undefined = (this._addToCode _p_space             indentation:indentation),
	fn _addNewLine             indentation:undefined = (this._addToCode _p_new_line          indentation:indentation),
	fn _addMemberDefReturn     indentation:undefined = (this._addToCode _p_comma_nl          indentation:indentation),
	fn _addStructKeyword       indentation:undefined = (this._addToCode (_p_struct_keyw + _p_space) indentation:indentation),
	fn _openParenthesis        indentation:undefined = (this._addToCode _p_open_parenthese   indentation:indentation),
	fn _closeParenthesis       indentation:undefined = (this._addToCode _p_close_parenthese  indentation:indentation),

	fn _addToCode c indentation:"" = (
		local indent = ""
		if (superclassof indentation) == Number then (for i=1 to indentation do (indent = indent + "\t"))
		this.struct_def = this.struct_def + indent + c
	),

	fn __addVariable v = (
		this._addToCode ((v.id as string) + " = undefined") indentation:1
		this._addMemberDefReturn()
	),
	fn __addFunction f = (
		this._addToCode f.code  indentation:1
		this._addMemberDefReturn()
	),
	fn __addVarInitCode v = (
		if v.value != undefined then (
			if this.protect_variables == true then (
				this._addToCode ("this." + (v.id as string) + " = set_" + (v.id as string) + " " + v.value + "\n")  indentation:2
			)else(
				this._addToCode ("this." + (v.id as string) + " = "+ v.value + "\n")  indentation:2
			)
			
		)
	),

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

	fn _defStructVariableAccessors = (
		local x = #()
		for v in this.struct_variables where (isKindOf v MetaStructVar) do (


			/* SETTER */			
			-- func name = set_varname
			local set_func = MetaStructFunc id:(("set_" + v.id) as name)

			-- infer correct type
			local convertType = undefined
			case v.type of (
				#string : (convertType="String")
				#integer : (convertType="Integer")
				#float : (convertType="Float")
				#name : (convertType="Name")
			)

			-- build code
			local c = "fn " + (set_func.id as string) + " v = (this."+v.id+" = (v as "+convertType+"))"

			set_func.code = c
			(this.__addFunction set_func)


			/* GETTER */
			local get_func = MetaStructFunc id:(("get_" + v.id) as name)
			get_func.code = "fn " + (get_func.id as string) + " = (this."+v.id+")"

			(this.__addFunction get_func)
			this._addToCode "\n"

		)
		--print x
	),


	fn _defConstructor = (
		_addToCode ("on create do ( \n")  indentation:1
		(for v in this.struct_variables where (isKindOf v MetaStructVar) do (this.__addVarInitCode v))
		_addToCode "\n\t)"
		_addNewLine
	),
	

	public
	-- Public from here
	fn generateStructCode = (
		_defStructIntro()

		-- Protect vars
		if this.protect_variables == true then (_addToCode "\tprivate\n")
		

		_addToCode "\n\t/*----------Variables----------*/\n" 
		_defStructVariables()

		-- Generate accessors - Protect vars
		if this.protect_variables == true then (
			_addToCode "\n\tpublic"
			_addToCode "\n\t/*----------Accessors----------*/\n"
			_defStructVariableAccessors()
		)

		_addToCode "\n\t/*----------Methods----------*/\n"
		_defStructFunctions()

		_addToCode "\n\t/*----------Constructor----------*/\n"

		_defConstructor()
		_defStructEnd()

		if this.skeleton == true then (
			_addNewLine()
			_addToCode ("global " + this.struct_name + " = " + this.struct_name + "()")
		)
	),

	fn getStructDef = (this.struct_def),

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
		skeleton:false

mmsg.generateStructCode()
x = execute mmsg.struct_def*/


-- Define object options
obj_meta_name = "MySuperStruct"
obj_meta_variables = #(
	(MetaStructVar id:#myInt value:"99" type:#integer),
	(MetaStructVar id:#myFloat value:"55.5" type:#float)
)

obj_meta_funcs = #(
	(MetaStructFunc id:#sayHello code:"fn sayHello = (print \"Helloworld!\")")
)

-- Instance a metastruct
obj_meta = MetaStruct struct_name:obj_meta_name \
			struct_variables:obj_meta_variables \
			struct_functions:obj_meta_funcs \
			skeleton:true \
			protect_variables:false


-- generate struct code
obj_meta.generateStructCode()
execute (obj_meta.getStructDef())
