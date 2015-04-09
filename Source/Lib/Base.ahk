/**************************************
	base classes
***************************************
*/

global gDBA_null := 0	; for better readability

/*
	Check for same (base) Type
*/
is(obj, type){
	
	;MsgBox % "is: " typeof(obj) " =? " typeof(type)

	if(IsObject(type))
		type := typeof(type)
	
	if( type == "" )
		throw Exception("ArgumentException: type is not a valid class/name!`n`tObject: " typeof(obj),-1)
	
	while(IsObject(obj)){
		if(obj.__Class == type){
			return true
		}
		obj := obj.base
	}
	return false
}

/*
* Returns the type of the given Object
*/
typeof(obj){
	if(IsObject(obj)){
		cls := obj.__Class
		
		if(cls != "")
			return cls
		
		while(IsObject(obj)){
			if(obj.__Class != ""){
				return obj.__Class
			}
			obj := obj.base
		}
		return "Object"
	}
	return "NonObject value(" obj ")"
}

inheritancePath( obj ){
	itree := []

	if(IsObject(obj)){
		
		ipath := "inheritance tree`n`n"
		
		while(IsObject(obj )){
			itree[A_index] := (Trim(obj.__Class) != "") ? obj.__Class : "{}"
			obj := obj.base
		}
		cnt := itree.MaxIndex()
		for i,cls in itree
		{
			j := cnt - (i - 1)
			ipath .= itree[j]	
			
			if(i < cnt)
			{
				ipath .= "`n"
				loop % i
					ipath .= "   " 
				ipath .= ">"
			}
		}
	}else
		ipath := "NonObject"
		
	return ipath
}


IsObjectMember(obj, memberStr){
	if(IsObject(obj)){
		return ObjHasKey(obj, memberStr) || IsMetaProperty(memberStr)
	}
}

/*
* Checks if the given property Name a reserved meta property name?
*/
IsMetaProperty(propertyName){
	static metaProps := ["base","__New","__Get","__Set","__Class"]
	return Contains(metaProps, propertyName)
}

/*
* Returns the exception detail as formated string
*/
ExceptionDetail(e){
	return "Exception Detail:`n" e.What "`n"  e.Message "`n`nin:`t" e.File "`nLine:`t" e.Line
}

Contains(list, value){
	for each, item in list
		if(item = value)
			return true
	return false
}



/**
* Provides some common used Exception Templates
*
*/
class gDBA_Exceptions
{
	NotImplemented(name=""){
		return Exception("A not implemented Method was called." (name != "" ? ": " name : "") ,-1)
	}
	
	MustOverride(name=""){
		return Exception("This Method must be overriden" (name != "" ? ": " name : "")  ,-1)
	}
	
	ArgumentException(furtherInfo=""){
		return Exception("A wrong Argument has been passed to this Method`n" furtherInfo,-1)
	}
}


;Base
{
	"".base.__Call := "Default__Warn"
	"".base.__Set  := "Default__Warn"
	"".base.__Get  := "Default__Warn"

	Default__Warn(nonobj, p1="", p2="", p3="", p4="")
	{
		ListLines
		MsgBox A non-object value was improperly invoked.`n`nSpecifically: %nonobj%
	}
}