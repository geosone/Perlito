use v5;

package Perlito5::Java::Runtime;

sub emit_java {
    my ($self, %args) = @_;
    my %java_classes = %{ $args{java_classes} // {} };

    my %number_binop = (
        add    => { op => '+',  returns => 'pInt',  num_returns => 'pNum'}, 
        sub    => { op => '-',  returns => 'pInt',  num_returns => 'pNum'},
        mul    => { op => '*',  returns => 'pInt',  num_returns => 'pNum'},
        div    => { op => '/',  returns => 'pNum',  num_returns => 'pNum'},
        num_eq => { op => '==', returns => 'pBool', num_returns => 'pBool' },
        num_ne => { op => '!=', returns => 'pBool', num_returns => 'pBool' },
        num_lt => { op => '<',  returns => 'pBool', num_returns => 'pBool' },
        num_le => { op => '<=', returns => 'pBool', num_returns => 'pBool' },
        num_gt => { op => '>',  returns => 'pBool', num_returns => 'pBool' },
        num_ge => { op => '>=', returns => 'pBool', num_returns => 'pBool' },
    );
    my %string_binop = (
        str_eq => { op => '== 0', returns => 'pBool' },
        str_ne => { op => '!= 0', returns => 'pBool' },
        str_lt => { op => '< 0',  returns => 'pBool' },
        str_le => { op => '<= 0', returns => 'pBool' },
        str_gt => { op => '> 0',  returns => 'pBool' },
        str_ge => { op => '>= 0', returns => 'pBool' },
    );

    my %native_to_perl = (
        int    => 'pInt',
        double => 'pNum',
        String => 'pString',
    );
    for (values %java_classes) {
        $native_to_perl{$_->{java_constructor}} = "p" . $_->{java_constructor};
    }

    return <<'EOT'
// start Perl-Java runtime
// this is generated code - see: lib/Perlito5/Java/Runtime.pm

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Iterator;
import java.util.regex.Pattern;
// import java.util.regex.Matcher;
EOT
        # import the Java classes
        # that were declared with
        #
        #   package MyJavaClass { Java }
        #
    . join('', ( map {
                    my $class = $_;
                    $class->{import} ? "import $class->{import};\n" : ()
            }
            values %java_classes
      ))
    . <<'EOT'
class pCx {
    public static final int VOID   = 0;
    public static final int SCALAR = 1;
    public static final int LIST   = 2;
    public static final pUndef  UNDEF  = new pUndef();
    public static final pBool   TRUE   = new pBool(true);
    public static final pBool   FALSE  = new pBool(false);
    public static final pString STDOUT = new pString("STDOUT");
    public static final pString STDERR = new pString("STDERR");
    public static final pString STDIN  = new pString("STDIN");
EOT
    . "    " . join("\n    ", @{ $args{java_constants} // [] } ) . "\n"
    . <<'EOT'
}
class pCORE {
    public static final pObject print(int want, pObject filehandle, pArray List__) {
        // TODO - write to filehandle
        for (int i = 0; i < List__.to_int(); i++) {
            System.out.print(List__.aget(i).to_string());
        }
        return new pInt(1);
    }
    public static final pObject say(int want, pObject filehandle, pArray List__) {
        // TODO - write to filehandle
        for (int i = 0; i < List__.to_int(); i++) {
            System.out.print(List__.aget(i).to_string());
        }
        System.out.println("");
        return new pInt(1);
    }
    public static final pObject say(String s) {
        // say() shortcut
        return pCORE.say(pCx.VOID, pCx.STDOUT, new pArray(new pString(s)));
    }
    public static final pObject die(int want, pArray List__) {
        for (int i = 0; i < List__.to_int(); i++) {
            System.err.print(List__.aget(i).to_string());
        }
        System.err.println("");
        throw new RuntimeException();
    }
    public static final pObject die(String s) {
        // die() shortcut
        return pCORE.die(pCx.VOID, new pArray(new pString(s)));
    }
    public static final pObject ref(int want, pArray List__) {
        return List__.aget(0).ref();
    }
    public static final pObject values(int want, pObject List__) {
        return want == pCx.LIST ? List__.values() : List__.values().scalar();
    }
    public static final pObject keys(int want, pObject List__) {
        return want == pCx.LIST ? List__.keys() : List__.keys().scalar();
    }
    public static final pObject each(int want, pObject List__) {
        return want == pCx.LIST ? List__.each() : List__.each().aget(0);
    }
    public static final pObject scalar(int want, pArray List__) {
        if (List__.to_int() == 0) {
            return pCx.UNDEF;
        }
        return List__.aget(-1).scalar();
    }
    public static final pObject join(int want, pArray List__) {
        String s = List__.shift().to_string();
        StringBuilder sb = new StringBuilder();
        boolean first = true;
        for (int i = 0; i < List__.to_int(); i++) {
            String item = List__.aget(i).to_string();
            if (first)
                first = false;
            else
                sb.append(s);
            sb.append(item);
        }
        return new pString(sb.toString());
    }
}
class pOp {
    // pOp implements operators: && || 
    //      and auxiliary functions
    //
    // note: '+' add() and '-' sub() are pObject methods, not implemented here.
    //
    // TODO - 'stack' should be reset when an exception happens
    // TODO - see Perlito5/Javascript2/Runtime.pm for more operator implementations

    private static ArrayList<pObject> stack = new ArrayList<pObject>();

    // context()
    //      - handles run-time scalar/list/void context in expression results
    public static final pObject context(int want, pObject arg) {
        if (want == 1) {
            return arg;
        }
        return arg.scalar();
    }

    // statement()
    //      - workaround for "Error: not a statement"
    //      - this is the compile-time version of context(null, arg)
    public static final void statement(pObject arg) { }
    public static final void statement() { }

    // and1(x) ? y : and3()
    public static final boolean and1(pObject arg1) {
        if (arg1.to_bool()) {
            return true;
        }
        else {
            stack.add(0, arg1);
            return false;
        }
    }
    public static final pObject and3() {
        return stack.remove(0);
    }

    // or1(x) ? or2() : y
    public static final boolean or1(pObject arg1) {
        if (arg1.to_bool()) {
            stack.add(0, arg1);
            return true;
        }
        else {
            return false;
        }
    }
    public static final pObject or2() {
        return stack.remove(0);
    }

    // $x++ when $x is pString
    public static final pObject string_increment(pObject s) {
        pCORE.die("not implemented string++");
        return s;

        // s = p5str(s);
        // if (s.match(/^[0123456789]/)) {
        //     return p5str(p5num(s)+1);
        // }
        // if (s.length < 2) {
        //     if (s.match(/[012345678ABCDEFGHIJKLMNOPQRSTUVWXYabcdefghijklmnopqrstuvwxy]/)) {
        //         return String.fromCharCode(s.charCodeAt(0) + 1);
        //     }
        //     if (s == "9") {
        //         return "10";
        //     }
        //     if (s == "Z") {
        //         return "AA";
        //     }
        //     if (s == "z") {
        //         return "aa";
        //     }
        //     return "1";
        // }
        // var c = p5str_inc(s.substr(s.length-1, 1));
        // if (c.length == 1) {
        //     return s.substr(0, s.length-1) + c;
        // }
        // return p5str_inc(s.substr(0, s.length-1)) + c.substr(c.length-1, 1);
    }
}
class pV {
    // pV implements namespaces and global variables
    //
    // TODO - import CORE subroutines in new namespaces, if needed
    // TODO - cache lookups in lexical variables (see pClosure implementation)

    public static final pHash var = new pHash();

    public static final pObject get(String name) {
        return var.hget_lvalue(name);
    }
    public static final pObject set(String name, pObject v) {
        return var.hset(name, v);
    }

    public static final pObject hash_get(String name) {
        return var.hget_hashref(name).get();
    }
    public static final pObject hash_set(String name, pObject v) {
        return var.hget_hashref(name).hash_deref_set(v);
    }

    public static final pObject array_get(String name) {
        return var.hget_arrayref(name).get();
    }
    public static final pObject array_set(String name, pObject v) {
        return var.hget_arrayref(name).array_deref_set(v);
    }
}
class pEnv {
    public static final void init() {
        pV.set("main|v_" + (char)34, new pString(" "));   // $" = " "
    }
}
class pObject {
    // extends java object ???
    public static final pString REF = new pString("");

    public pObject() {
    }
EOT
        # add interfaces to Java classes
        # that were declared with
        #
        #   package MyJavaClass { Java }
        #
    . join('', ( map {
                    my $class = $_;
                    my $java_class_name = $class->{java_constructor};
                    my $perl_to_java = $class->{perl_to_java};
                    $class->{import} ? 
                    "    public ${java_class_name} ${perl_to_java}() {\n"
                  . "        pCORE.die(\"error .${perl_to_java}!\");\n"
                  . "        return null;\n"
                  . "    }\n" : ()
            }
            values %java_classes
      ))
    . <<'EOT'
    public String to_string() {
        return this.toString();
    }
    public int to_int() {
        pCORE.die("error .to_int!");
        return 0;
    }
    public pObject end_of_array_index() {
        return pCORE.die("Not an ARRAY reference");
    }
    public double to_num() {
        pCORE.die("error .to_num!");
        return 0.0;
    }
    public boolean to_bool() {
        pCORE.die("error .to_bool!");
        return true;
    }
    public boolean is_undef() {
        return false;
    }
    public pObject apply(int want, pObject List__) {
        // $ perl -e ' $a = 5; $a->() '
        // Undefined subroutine &main::5 called
        pCORE.die("subroutine call error");
        return this;
    }

    public pObject get_arrayref() {
        return pCORE.die("Not an ARRAY reference");
    }
    public pObject get_hashref() {
        return pCORE.die("Not a HASH reference");
    }

    public pObject hget_scalarref(pObject i) {
        pCORE.die("Not a SCALAR reference");
        return this;
    }
    public pObject hget_scalarref(String i) {
        pCORE.die("Not a SCALAR reference");
        return this;
    }
    public pObject scalar_deref_set(pObject v) {
        pCORE.die("Not a SCALAR reference");
        return this;
    }
    public pObject aget_scalarref(pObject i) {
        pCORE.die("Not a SCALAR reference");
        return this;
    }
    public pObject aget_scalarref(int i) {
        pCORE.die("Not a SCALAR reference");
        return this;
    }

    public pObject array_deref() {
        pCORE.die("Not an ARRAY reference");
        return this;
    }
    public pObject array_deref_set(pObject i) {
        pCORE.die("Not an ARRAY reference");
        return this;
    }

    public pObject hget_arrayref(pObject i) {
        pCORE.die("Not a HASH reference");
        return this;
    }
    public pObject hget_arrayref(String i) {
        pCORE.die("Not a HASH reference");
        return this;
    }
    public pObject hget_hashref(pObject i) {
        pCORE.die("Not a HASH reference");
        return this;
    }
    public pObject hget_hashref(String i) {
        pCORE.die("Not a HASH reference");
        return this;
    }

    public pObject aget_arrayref(pObject i) {
        pCORE.die("Not an ARRAY reference");
        return this;
    }
    public pObject aget_arrayref(int i) {
        pCORE.die("Not an ARRAY reference");
        return this;
    }
    public pObject aget_hashref(pObject i) {
        pCORE.die("Not an ARRAY reference");
        return this;
    }
    public pObject aget_hashref(int i) {
        pCORE.die("Not an ARRAY reference");
        return this;
    }

    public pObject hash_deref() {
        pCORE.die("Not a HASH reference");
        return this;
    }
    public pObject hash_deref_set(pObject i) {
        pCORE.die("Not a HASH reference");
        return this;
    }

    public pObject hget(pObject i) {
        pCORE.die("Not a HASH reference");
        return this;
    }
    public pObject hget(String i) {
        pCORE.die("Not a HASH reference");
        return this;
    }
    public pObject hget_lvalue(pObject i) {
        pCORE.die("Not a HASH reference");
        return this;
    }
    public pObject hget_lvalue(String i) {
        pCORE.die("Not a HASH reference");
        return this;
    }

    public pObject hset(pObject s, pObject v) {
        pCORE.die("Not a HASH reference");
        return this;
    }
    public pObject hset(String s, pObject v) {
        pCORE.die("Not a HASH reference");
        return this;
    }

    public pObject aget(pObject i) {
        pCORE.die("Not an ARRAY reference");
        return this;
    }
    public pObject aget(int i) {
        pCORE.die("Not an ARRAY reference");
        return this;
    }
    public pObject aset(pObject i, pObject v) {
        pCORE.die("Not an ARRAY reference");
        return this;
    }
    public pObject to_array() {
        pCORE.die("Not an ARRAY reference");
        return this;
    }
    public pObject length_of_array() {
        pCORE.die("Not an ARRAY reference");
        return this;
    }
    public pObject values() {
        pCORE.die("Type of argument to values on reference must be unblessed hashref or arrayref");
        return this;
    }
    public pObject keys() {
        pCORE.die("Type of argument to keys on reference must be unblessed hashref or arrayref");
        return this;
    }
    public pObject each() {
        pCORE.die("Type of argument to each on reference must be unblessed hashref or arrayref");
        return this;
    }
    public pObject exists(pObject i) {
        pCORE.die("exists argument is not a HASH or ARRAY element or a subroutine");
        return this;
    }
    public pObject delete(pObject i) {
        pCORE.die("delete argument is not a HASH or ARRAY element or slice");
        return this;
    }
    public pObject set(pObject o) {
        pCORE.die("Modification of a read-only value attempted");
        return this;
    }
    public pObject get() {
        pCORE.die("error .get!");
        return this;
    }
    public boolean is_int() {
        return false;
    }
    public boolean is_num() {
        return false;
    }
    public boolean is_string() {
        return false;
    }
    public boolean is_bool() {
        return false;
    }
    public boolean is_hash() {
        return false;
    }
    public boolean is_array() {
        return false;
    }
    public boolean is_scalar() {
        return false;
    }
    public boolean is_scalarref() {
        return false;
    }
    public boolean is_arrayref() {
        return false;
    }
    public boolean is_hashref() {
        return false;
    }

    public pObject _decr() {
        // --$x
        return new pInt(-1);
    }
    public pObject _incr() {
        // ++$x
        return new pInt(1);
    }
    public pObject pre_decr() {
        // --$x
        pCORE.die("Can't modify constant item in predecrement (--)");
        return this;
    }
    public pObject post_decr() {
        // $x--
        pCORE.die("Can't modify constant item in postdecrement (--)");
        return this;
    }
    public pObject pre_incr() {
        // ++$x
        pCORE.die("Can't modify constant item in preincrement (++)");
        return this;
    }
    public pObject post_incr() {
        // $x++
        pCORE.die("Can't modify constant item in postincrement (++)");
        return this;
    }

    public pObject ref() {
        return REF;
    }
    public pObject scalar() {
        return this;
    }
EOT
    . ( join('', map {
            my $perl = $_;
            my $native  = $number_binop{$perl}{op};
            my $returns = $number_binop{$perl}{returns};
"    public pObject ${perl}(pObject s) {
        return s.${perl}2(this);
    }
    public pObject ${perl}2(pObject s) {
        return new ${returns}( s.to_int() ${native} this.to_int() );
    }
"
            }
            keys %number_binop ))

    . ( join('', map {
            my $perl = $_;
            my $native  = $string_binop{$perl}{op};
            my $returns = $string_binop{$perl}{returns};
"    public pObject ${perl}(pObject b) {
        return new ${returns}(this.to_string().compareTo(b.to_string()) ${native});
    }
"
            }
            keys %string_binop ))

    . <<'EOT'
}
class pReference extends pObject {
    public static final pString REF = new pString("REF");

    public String to_string() {
        return this.ref().to_string() + "(0x" + this.hashCode() + ")";
    }
    public pObject ref() {
        return REF;
    }
}
class pRegex extends pReference {
    public Pattern p;
    // public Matcher m;
    public static final pString REF = new pString("Regexp");

    public pRegex(String p, int flags) {
        this.p = Pattern.compile(p, flags);
    }
    public pRegex(pObject p, int flags) {
        this.p = Pattern.compile(p.to_string(), flags);
    }
    public String to_string() {
        // TODO - show flags
        return this.p.toString();
    }
    public pObject ref() {
        return REF;
    }
}
class pClosure extends pReference {
    public pObject[] env;       // new pObject[]{ v1, v2, v3 }
    public pObject prototype;    // '$$$'
    public static final pString REF = new pString("CODE");

    public pClosure(pObject prototype, pObject[] env) {
        this.prototype = prototype;
        this.env = env;
    }
    // Note: apply() is inherited from pObject
    public pObject apply(int want, pObject List__) {
        pCORE.die("it looks like you have a closure without a block");
        return this;
    }
    public pObject ref() {
        return REF;
    }
}
class pScalarRef extends pReference {
    private pObject o;
    public static final pString REF = new pString("SCALAR");

    public pScalarRef(pScalar o) {
        this.o = o;
    }
    public pScalarRef(pObject o) {
        // TODO - make readonly value like in \1
        this.o = o;
    }
    public pObject scalar_deref_set(pObject v) {
        return this.o.set(v);
    }
    public boolean is_scalarref() {
        return true;
    }
    public pObject get() {
        return this.o;
    }
    public pObject ref() {
        return REF;
    }
}
class pArrayRef extends pArray {
    public static final pString REF = new pString("ARRAY");

    public String to_string() {
        return this.ref().to_string() + "(0x" + this.hashCode() + ")";
    }
    public pArrayRef() {
        this.each_iterator = 0;
        this.a = new ArrayList<pObject>();
    }
    public pArrayRef(pArray o) {
        this.a = o.a;
        this.each_iterator = o.each_iterator;
    }
    public pObject set(pArray o) {
        this.a = o.a;
        this.each_iterator = o.each_iterator;
        return o;
    }
    public pObject get() {
        pArray o = new pArray();
        o.a = this.a;
        return o;
    }
    public pObject array_deref() {
        pArray o = new pArray();
        o.a = this.a;
        return o;
    }
    public pObject array_deref_set(pObject v) {
        super.set(v);
        return v;
    }
    public boolean is_array() {
        return false;
    }
    public boolean is_arrayref() {
        return true;
    }
    public pObject scalar() {
        return this;
    }
    public pObject ref() {
        return REF;
    }
}
class pHashRef extends pHash {
    public static final pString REF = new pString("HASH");

    public String to_string() {
        return this.ref().to_string() + "(0x" + this.hashCode() + ")";
    }
    public pHashRef() {
        this.h = new HashMap<String, pObject>();
        this.each_iterator = null;
    }
    public pHashRef(pHash o) {
        this.h = o.h;
        this.each_iterator = o.each_iterator;
    }
    public pObject set(pHash o) {
        this.h = o.h;
        this.each_iterator = o.each_iterator;
        return o;
    }
    public pObject get() {
        pHash o = new pHash();
        o.h = this.h;
        return o;
    }
    public pObject hash_deref() {
        pHash o = new pHash();
        o.h = this.h;
        return o;
    }
    public pObject hash_deref_set(pObject v) {
        super.set(v);
        return v;
    }
    public boolean is_hash() {
        return false;
    }
    public boolean is_hashref() {
        return true;
    }
    public pObject scalar() {
        return this;
    }
    public pObject ref() {
        return REF;
    }
}
class pScalar extends pObject {
    private pObject o;

    // Note: several versions of pScalar()
    public pScalar() {
        this.o = pCx.UNDEF;
    }
    public pScalar(pObject o) {
        this.o = o;
    }
    public pScalar(pScalar o) {
        this.o = o.get();
    }
    public pScalar(pArray o) {
        // $a = @x
        this.o = o.scalar();
    }
    public pScalar(pHash o) {
        // $a = %x
        this.o = o.scalar();
    }

    public pObject get() {
        return this.o;
    }
    public pObject get_scalarref() {
        if (this.o.is_undef()) {
            pScalarRef ar = new pScalarRef(new pScalar());
            this.o = ar;
            return ar;
        }
        else if (this.o.is_scalarref()) {
            return this.o;
        }
        // Modification of a read-only value attempted
        return this.o;
    }
    public pObject get_arrayref() {
        if (this.o.is_undef()) {
            pArrayRef ar = new pArrayRef();
            this.o = ar;
            return ar;
        }
        else if (this.o.is_arrayref()) {
            return this.o;
        }
        return pCORE.die("Not an ARRAY reference");
    }
    public pObject get_hashref() {
        if (this.o.is_undef()) {
            pHashRef hr = new pHashRef();
            this.o = hr;
            return this.o;
        }
        else if (this.o.is_hashref()) {
            return this.o;
        }
        return pCORE.die("Not a HASH reference");
    }
    public pObject aget(pObject i) {
        return this.o.aget(i);
    }
    public pObject aget(int i) {
        return this.o.aget(i);
    }

    public pObject aget_scalarref(pObject i) {
        if (this.o.is_undef()) {
            this.o = new pArrayRef();
        }
        return this.o.aget_scalarref(i);
    }
    public pObject aget_arrayref(pObject i) {
        if (this.o.is_undef()) {
            this.o = new pArrayRef();
        }
        return this.o.aget_arrayref(i);
    }
    public pObject aget_hashref(pObject i) {
        if (this.o.is_undef()) {
            this.o = new pArrayRef();
        }
        return this.o.aget_hashref(i);
    }

    public pObject aset(pObject i, pObject v) {
        return this.o.aset(i, v);
    }
    public pObject hget(pObject i) {
        return this.o.hget(i);
    }
    public pObject hget(String i) {
        return this.o.hget(i);
    }

    public pObject hget_scalarref(pObject i) {
        if (this.o.is_undef()) {
            this.o = new pHashRef();
        }
        return this.o.hget_scalarref(i);
    }
    public pObject hget_arrayref(pObject i) {
        if (this.o.is_undef()) {
            this.o = new pHashRef();
        }
        return this.o.hget_arrayref(i);
    }
    public pObject hget_hashref(pObject i) {
        if (this.o.is_undef()) {
            this.o = new pHashRef();
        }
        return this.o.hget_hashref(i);
    }

    public pObject hset(pObject s, pObject v) {
        return this.o.hset(s, v);
    }
    public pObject hset(String s, pObject v) {
        return this.o.hset(s, v);
    }

    public pObject scalar_deref() {
        return this.get_scalarref().get();
    }
    public pObject scalar_deref_set(pObject v) {
        return this.get_scalarref().scalar_deref_set(v);
    }

    public pObject array_deref() {
        // @$x doesn't autovivify
        if (this.o.is_undef()) {
            return new pArray();
        }
        else if (this.o.is_arrayref()) {
            return this.o.get();
        }
        return pCORE.die("Not an ARRAY reference");
    }
    public pObject array_deref_set(pObject v) {
        // @$x = ...
        if (this.o.is_undef()) {
            this.o = new pArrayRef();
            return this.o.array_deref_set(v);
        }
        else if (this.o.is_arrayref()) {
            return this.o.array_deref_set(v);
        }
        return pCORE.die("Not an ARRAY reference");
    }

    public pObject hash_deref() {
        // %$x doesn't autovivify
        if (this.o.is_undef()) {
            return new pHash();
        }
        else if (this.o.is_hashref()) {
            return this.o.get();
        }
        return pCORE.die("Not a HASH reference");
    }
    public pObject hash_deref_set(pObject v) {
        // %$x = ...
        if (this.o.is_undef()) {
            this.o = new pHashRef();
            return this.o.hash_deref_set(v);
        }
        else if (this.o.is_hashref()) {
            return this.o.hash_deref_set(v);
        }
        return pCORE.die("Not a HASH reference");
    }
    public pObject apply(int want, pObject List__) {
        return this.o.apply(want, List__);
    }

    // Note: several versions of set()
    public pObject set(pObject o) {
        this.o = o;
        return this;
    }
    public pObject set(pScalar o) {
        this.o = o.get();
        return this;
    }
    public pObject set(pArray o) {
        // $a = @x
        this.o = o.scalar();
        return this;
    }
    public pObject set(pHash o) {
        // $a = %x
        this.o = o.scalar();
        return this;
    }
EOT
    . ( join('', map {
            my $native = $_;
            my $perl   = $native_to_perl{$native};
            $native && $perl ? 
"    public pObject set($native s) {
        this.o = new $perl(s);
        return this;
    }
" : ()
            }
            keys %native_to_perl ))

    . <<'EOT'
    public String to_string() {
        return this.o.to_string();
    }
    public int to_int() {
        return this.o.to_int();
    }
    public double to_num() {
        return this.o.to_num();
    }
    public boolean to_bool() {
        return this.o.to_bool();
    }
EOT
    . ( join('', map {
            my $perl = $_;
            my $native = $number_binop{$perl}{op};
"    public pObject ${perl}(pObject s) {
        return s.${perl}2(this);
    }
"
            }
            keys %number_binop ))

    . <<'EOT'
    public boolean is_int() {
        return this.o.is_int();
    }
    public boolean is_num() {
        return this.o.is_num();
    }
    public boolean is_string() {
        return this.o.is_string();
    }
    public boolean is_bool() {
        return this.o.is_bool();
    }
    public boolean is_undef() {
        return this.o.is_undef();
    }
    public boolean is_scalar() {
        return true;
    }

    public pObject pre_decr() {
        // --$x
        this.o = this.o._decr();
        return this.o;
    }
    public pObject post_decr() {
        // $x--
        pObject res = this.o;
        this.o = this.o._decr();
        return res;
    }
    public pObject pre_incr() {
        // ++$x
        this.o = this.o._incr();
        return this.o;
    }
    public pObject post_incr() {
        // $x++
        pObject res = this.o;
        this.o = this.o._incr();
        return res;
    }

    public pObject scalar() {
        return this.o;
    }
    public pObject ref() {
        return this.o.ref();
    }
EOT
        # add "unbox" accessors to Java classes
        # that were declared with
        #
        #   package MyJavaClass { Java }
        #
    . join('', ( map {
                    my $class = $_;
                    my $java_class_name = $class->{java_constructor};
                    my $perl_to_java = $class->{perl_to_java};
                    $class->{import} ? 
"    public ${java_class_name} ${perl_to_java}() {
        return this.o.${perl_to_java}();
    }
" : ()
            }
            values %java_classes
      ))

    . <<'EOT'
}
class pArray extends pObject {
    public ArrayList<pObject> a;
    public int each_iterator;
    public pArray() {
        this.each_iterator = 0;
        this.a = new ArrayList<pObject>();
    }
    public pArray(pObject... args) {
        ArrayList<pObject> aa = new ArrayList<pObject>();
        for (pObject s : args) {
            if (s.is_hash()) {
                // @x = %x;
                s = s.to_array();
            }
            if (s.is_array()) {
                // @x = ( @x, @y );
                for (int i = 0; i < s.to_int(); i++) {
                    aa.add(s.aget(i));
                }
            }
            else {
                aa.add(s);
            }
        }
        this.each_iterator = 0;
        this.a = aa;
    }
    public pObject set(pObject s) {
        this.a.clear();
        if (s.is_hash()) {
            // @x = %x;
            s = s.to_array();
        }
        if (s.is_array()) {
            // @x = ( @x, @y );
            for (int i = 0; i < s.to_int(); i++) {
                this.a.add(s.aget(i));
            }
        }
        else {
            this.a.add(s);
        }
        this.each_iterator = 0;
        return this;
    }

    public pObject aget(pObject i) {
        int pos  = i.to_int();
        if (pos < 0) {
            pos = this.a.size() + pos;
        }
        if (pos < 0 || pos >= this.a.size()) {
            return pCx.UNDEF;
        }
        return this.a.get(pos);
    }
    public pObject aget(int i) {
        int pos  = i;
        if (pos < 0) {
            pos = this.a.size() + pos;
        }
        if (pos < 0 || pos >= this.a.size()) {
            return pCx.UNDEF;
        }
        return this.a.get(pos);
    }

    public pObject get_scalar(pObject i) {
        // $$x
        pObject o = this.aget(i);
        if (o.is_undef()) {
            pScalar a = new pScalar();
            this.aset(i, new pScalarRef(a));
            return a;
        }
        else if (o.is_scalarref()) {
            return o.get();
        }
        // Modification of a read-only value attempted
        // return pCORE.die("Not an SCALAR reference");
        return o;
    }
    public pObject aget_scalarref(pObject i) {
        pObject o = this.aget(i);
        if (o.is_undef()) {
            pScalarRef ar = new pScalarRef(new pScalar());
            this.aset(i, ar);
            return ar;
        }
        else if (o.is_scalarref()) {
            return o;
        }
        return pCORE.die(pCx.VOID, new pArray(new pString("Not a SCALAR reference")));
    }
    public pObject aget_scalarref(int i) {
        pObject o = this.aget(i);
        if (o.is_undef()) {
            pScalarRef ar = new pScalarRef(new pScalar());
            this.aset(i, ar);
            return ar;
        }
        else if (o.is_scalarref()) {
            return o;
        }
        return pCORE.die(pCx.VOID, new pArray(new pString("Not a SCALAR reference")));
    }

    public pObject aget_arrayref(pObject i) {
        pObject o = this.aget(i);
        if (o.is_undef()) {
            pArrayRef ar = new pArrayRef();
            this.aset(i, ar);
            return ar;
        }
        else if (o.is_arrayref()) {
            return o;
        }
        return pCORE.die(pCx.VOID, new pArray(new pString("Not an ARRAY reference")));
    }
    public pObject aget_arrayref(int i) {
        pObject o = this.aget(i);
        if (o.is_undef()) {
            pArrayRef ar = new pArrayRef();
            this.aset(i, ar);
            return ar;
        }
        else if (o.is_arrayref()) {
            return o;
        }
        return pCORE.die(pCx.VOID, new pArray(new pString("Not an ARRAY reference")));
    }

    public pObject aget_hashref(pObject i) {
        pObject o = this.aget(i);
        if (o.is_undef()) {
            pHashRef hr = new pHashRef();
            this.aset(i, hr);
            return hr;
        }
        else if (o.is_hashref()) {
            return o;
        }
        return pCORE.die(pCx.VOID, new pArray(new pString("Not a HASH reference")));
    }
    public pObject aget_hashref(int i) {
        pObject o = this.aget(i);
        if (o.is_undef()) {
            pHashRef hr = new pHashRef();
            this.aset(i, hr);
            return hr;
        }
        else if (o.is_hashref()) {
            return o;
        }
        return pCORE.die(pCx.VOID, new pArray(new pString("Not a HASH reference")));
    }

    public pObject get_hash(int i) {
        pObject o = this.aget(i);
        if (o.is_undef()) {
            pHashRef hr = new pHashRef();
            this.aset(i, hr);
            return hr;
        }
        else if (o.is_hashref()) {
            return o;
        }
        return pCORE.die(pCx.VOID, new pArray(new pString("Not a HASH reference")));
    }

    // Note: multiple versions of set()
    public pObject aset(pObject i, pObject v) {
        int size = this.a.size();
        int pos  = i.to_int();
        if (pos < 0) {
            pos = size + pos;
        }
        while (size < pos) {
            this.a.add( pCx.UNDEF );
            size++;
        }
        this.a.add(pos, v.scalar());
        return v;
    }
    public pObject aset(int i, pObject v) {
        int size = this.a.size();
        int pos  = i;
        if (pos < 0) {
            pos = size + pos;
        }
        while (size < pos) {
            this.a.add( pCx.UNDEF );
            size++;
        }
        this.a.add(pos, v.scalar());
        return v;
    }
    public pObject aset(pObject i, pScalar v) {
        int size = this.a.size();
        int pos  = i.to_int();
        if (pos < 0) {
            pos = size + pos;
        }
        while (size < pos) {
            this.a.add( pCx.UNDEF );
            size++;
        }
        this.a.add(pos, v.get());
        return v;
    }
EOT
    . ( join('', map {
            my $native = $_;
            my $perl   = $native_to_perl{$native};
            $native && $perl ?
"    public pObject aset(pObject i, $native s) {
        return this.aset(i, new $perl(s));
    }
    public pObject aset(int i, $native s) {
        return this.aset(i, new $perl(s));
    }
" : ()
            }
            keys %native_to_perl ))

    . <<'EOT'

    // Note: multiple versions of push()
    public pObject push(pObject v) {
        this.a.add(v.scalar());
        return this.length_of_array();
    }
    public pObject push(pScalar v) {
        this.a.add(v.get());
        return this.length_of_array();
    }
    public pObject push(pArray args) {
        for (int i = 0; i < args.to_int(); i++) {
            pObject s = args.aget(i);
            if (s.is_hash()) {
                // @x = %x;
                s = s.to_array();
            }
            if (s.is_array()) {
                this.push(s);
            }
            else {
                this.a.add(s);
            }
        }
        return this.length_of_array();
    }

    // Note: multiple versions of unshift()
    public pObject unshift(pObject v) {
        this.a.add(0, v.scalar());
        return this.length_of_array();
    }
    public pObject unshift(pScalar v) {
        this.a.add(0, v.get());
        return this.length_of_array();
    }
    public pObject unshift(pArray args) {
        for (int i = args.to_int() - 1; i >= 0; i--) {
            pObject s = args.aget(i);
            if (s.is_hash()) {
                // @x = %x;
                s = s.to_array();
            }
            if (s.is_array()) {
                this.unshift(s);
            }
            else {
                this.a.add(0, s);
            }
        }
        return this.length_of_array();
    }

    public pObject pop() {
        int size = this.a.size() - 1;
        if (size >= 0) {
            return this.a.remove(size);
        }
        else {
            return pCx.UNDEF;
        }
    }
    public pObject shift() {
        int size = this.a.size();
        if (size > 0) {
            return this.a.remove(0);
        }
        else {
            return pCx.UNDEF;
        }
    }
    public pObject exists(pObject i) {
        pCORE.die("TODO - array exists");
        return this;
    }
    public pObject delete(pObject i) {
        pCORE.die("TODO - array delete");
        return this;
    }
    public pObject values() {
        // return a copy
        return new pArray(this);
    }
    public pObject keys() {
        pArray aa = new pArray();
        int size = this.a.size();
        for (int i = 0; i < size; i++) {
            aa.push(new pInt(i));
        }
        return aa;
    }
    public pObject each() {
        pArray aa = new pArray();
        int size = this.a.size();
        if (this.each_iterator < size) {
            aa.push(new pInt(this.each_iterator));
            aa.push(this.aget(this.each_iterator));
            this.each_iterator++;
        }
        else {
            // return empty list
            this.each_iterator = 0;
        }
        return aa;
    }
    public String to_string() {
        StringBuilder sb = new StringBuilder();
        int size = this.a.size();
        for (int i = 0; i < size; i++) {
            String item = this.a.get(i).to_string();
            sb.append(item);
        }
        return sb.toString();
    }
    public int to_int() {
        return this.a.size();
    }
    public pObject length_of_array() {
        return new pInt(this.a.size());
    }
    public pObject end_of_array_index() {
        return new pInt(this.a.size() - 1);
    }
    public double to_num() {
        return 0.0 + this.to_int();
    }
    public boolean to_bool() {
        return (this.a.size() > 0);
    }
    public boolean is_int() {
        return false;
    }
    public boolean is_num() {
        return false;
    }
    public boolean is_string() {
        return false;
    }
    public boolean is_bool() {
        return false;
    }
    public boolean is_array() {
        return true;
    }
    public pObject scalar() {
        return this.length_of_array();
    }
}
class pHash extends pObject {
    public HashMap<String, pObject> h;
    public Iterator<Map.Entry<String, pObject>> each_iterator;

    public pHash() {
        this.each_iterator = null;
        this.h = new HashMap<String, pObject>();
    }
    public pHash(pObject... args) {
        pHash hh = new pHash();
        int args_size = args.length;
        for (int i = 0; i < args_size; i++) {
            pObject s = args[i];
            if (s.is_hash()) {
                // @x = %x;
                s = s.to_array();
            }
            if (s.is_array()) {
                // %x = ( @x, @y );
                int array_size = s.to_int();
                for (int j = 0; j < array_size; j++) {
                    pObject key = s.aget(j);
                    j++;
                    pObject value;
                    if ( j >= array_size ) {
                        // TODO - emit warning about odd number of arguments
                        value = pCx.UNDEF;
                    }
                    else {
                        value = s.aget(j);
                    }
                    hh.hset(key, value);
                }
            }
            else {
                i++;
                pObject value;
                if ( i >= args_size ) {
                    // TODO - emit warning about odd number of arguments
                    value = pCx.UNDEF;
                }
                else {
                    value = args[i];
                }
                hh.hset(s, value);
            }
        }
        this.each_iterator = null;
        this.h = hh.to_HashMap();
    }
    private HashMap<String, pObject> to_HashMap() {
        return this.h;
    }
    public pObject set(pObject s) {
        this.h.clear();
        if (s.is_hash()) {
            // @x = %x;
            s = s.to_array();
        }
        if (s.is_array()) {
            // %x = ( @x, @y );
            int array_size = s.to_int();
            for (int j = 0; j < array_size; j++) {
                pObject key = s.aget(j);
                j++;
                pObject value;
                if ( j >= array_size ) {
                    // TODO - emit warning about odd number of arguments
                    value = pCx.UNDEF;
                }
                else {
                    value = s.aget(j);
                }
                this.hset(key, value);
            }
        }
        else {
            // TODO - emit warning about odd number of arguments
            this.hset(s, pCx.UNDEF);
        }
        this.each_iterator = null;
        return this;
    }

    public pObject to_array() {
        pArray aa = new pArray();
        for (Map.Entry<String, pObject> entry : this.h.entrySet()) {
            String key = entry.getKey();
            pObject value = entry.getValue();
            aa.push(new pString(key));
            aa.push(value);
        }
        return aa;
    }

    public pObject hget(pObject i) {
        pObject o = this.h.get(i.to_string());
        if (o == null) {
            return pCx.UNDEF;
        }
        return o;
    }
    public pObject hget(String i) {
        pObject o = this.h.get(i);
        if (o == null) {
            return pCx.UNDEF;
        }
        return o;
    }
    public pObject hget_lvalue(pObject i) {
        pObject o = this.h.get(i.to_string());
        if (o == null) {
            pScalar a = new pScalar();
            this.h.put(i.to_string(), a);
            return a;
        }
        else if (o.is_scalar()) {
            return o;
        }
        pScalar a = new pScalar(o);
        this.h.put(i.to_string(), a);
        return a;
    }
    public pObject hget_lvalue(String i) {
        pObject o = this.h.get(i);
        if (o == null) {
            pScalar a = new pScalar();
            this.h.put(i, a);
            return a;
        }
        else if (o.is_scalar()) {
            return o;
        }
        pScalar a = new pScalar(o);
        this.h.put(i, a);
        return a;
    }

    public pObject get_scalar(pObject i) {
        // $$x
        pObject o = this.hget(i);
        if (o.is_undef()) {
            pScalar a = new pScalar();
            this.hset(i, new pScalarRef(a));
            return a;
        }
        else if (o.is_scalarref()) {
            return o.get();
        }
        // Modification of a read-only value attempted
        // return pCORE.die("Not an SCALAR reference");
        return o;
    }

    public pObject hget_scalarref(pObject i) {
        pObject o = this.hget(i);
        if (o.is_undef()) {
            pScalarRef ar = new pScalarRef(new pScalar());
            this.hset(i, ar);
            return ar;
        }
        else if (o.is_scalarref()) {
            return o;
        }
        // Modification of a read-only value attempted
        return o;
    }
    public pObject hget_scalarref(String i) {
        pObject o = this.hget(i);
        if (o.is_undef()) {
            pScalarRef ar = new pScalarRef(new pScalar());
            this.hset(i, ar);
            return ar;
        }
        else if (o.is_scalarref()) {
            return o;
        }
        // Modification of a read-only value attempted
        return o;
    }

    public pObject hget_arrayref(pObject i) {
        pObject o = this.hget(i);
        if (o.is_undef()) {
            pArrayRef ar = new pArrayRef();
            this.hset(i, ar);
            return ar;
        }
        else if (o.is_arrayref()) {
            return o;
        }
        return pCORE.die(pCx.VOID, new pArray(new pString("Not an ARRAY reference")));
    }
    public pObject hget_arrayref(String i) {
        pObject o = this.hget(i);
        if (o.is_undef()) {
            pArrayRef ar = new pArrayRef();
            this.hset(i, ar);
            return ar;
        }
        else if (o.is_arrayref()) {
            return o;
        }
        return pCORE.die(pCx.VOID, new pArray(new pString("Not an ARRAY reference")));
    }

    public pObject hget_hashref(pObject i) {
        pObject o = this.hget(i);
        if (o.is_undef()) {
            pHashRef hr = new pHashRef();
            this.hset(i, hr);
            return hr;
        }
        else if (o.is_hashref()) {
            return o;
        }
        return pCORE.die(pCx.VOID, new pArray(new pString("Not a HASH reference")));
    }
    public pObject hget_hashref(String i) {
        pObject o = this.hget(i);
        if (o.is_undef()) {
            pHashRef hr = new pHashRef();
            this.hset(i, hr);
            return hr;
        }
        else if (o.is_hashref()) {
            return o;
        }
        return pCORE.die(pCx.VOID, new pArray(new pString("Not a HASH reference")));
    }

    // Note: multiple versions of set()
    public pObject hset(pObject s, pObject v) {
        this.h.put(s.to_string(), v.scalar());
        return v;
    }
    public pObject hset(String s, pObject v) {
        this.h.put(s, v.scalar());
        return v;
    }
    public pObject hset(pObject s, pScalar v) {
        this.h.put(s.to_string(), v.get());
        return v;
    }
    public pObject hset(String s, pScalar v) {
        this.h.put(s, v.get());
        return v;
    }

    public pObject exists(pObject i) {
        return this.h.containsKey(i) ? pCx.TRUE : pCx.FALSE;
    }
    public pObject delete(pObject i) {
        pObject r = this.h.remove(i);
        if (r == null) {
            return pCx.UNDEF;
        }
        return r;
    }
    public pObject values() {
        pArray aa = new pArray();
        for (Map.Entry<String, pObject> entry : this.h.entrySet()) {
            pObject value = entry.getValue();
            aa.push(value);
        }
        return aa;
    }
    public pObject keys() {
        pArray aa = new pArray();
        for (Map.Entry<String, pObject> entry : this.h.entrySet()) {
            String key = entry.getKey();
            aa.push(new pString(key));
        }
        return aa;
    }
    public pObject each() {
        if (this.each_iterator == null) {
            this.each_iterator = this.h.entrySet().iterator();
        }
        pArray aa = new pArray();
        if (this.each_iterator.hasNext()) {
            Map.Entry<String, pObject> entry = this.each_iterator.next();
            String key = entry.getKey();
            aa.push(new pString(key));
            pObject value = entry.getValue();
            aa.push(value);
        }
        else {
             // return empty list
             this.each_iterator = null;
        }
        return aa;
    }
EOT
    . ( join('', map {
            my $native = $_;
            my $perl   = $native_to_perl{$native};
            $native && $perl ?
"    public pObject hset(pObject s, $native v) {
        return this.hset(s, new $perl(v));
    }
    public pObject hset(String s, $native v) {
        return this.hset(s, new $perl(v));
    }
" : ()
            }
            keys %native_to_perl ))

    . <<'EOT'

    public String to_string() {
        // TODO
        return "" + this.hashCode();
    }
    public int to_int() {
        // TODO
        return this.hashCode();
    }
    public double to_num() {
        return 0.0 + this.to_int();
    }
    public boolean to_bool() {
        return true;
    }
    public boolean is_int() {
        return false;
    }
    public boolean is_num() {
        return false;
    }
    public boolean is_string() {
        return false;
    }
    public boolean is_bool() {
        return false;
    }
    public boolean is_hash() {
        return true;
    }
    public pObject scalar() {
        return new pString(this.to_string());
    }
}
class pUndef extends pObject {
    public pUndef() {
    }
    public pObject apply(int want, pObject List__) {
        // $a->()
        pCORE.die("Can't use an undefined value as a subroutine reference");
        return this;
    }
    public int to_int() {
        return 0;
    }
    public double to_num() {
        return 0.0;
    }
    public String to_string() {
        return "";
    }
    public boolean to_bool() {
        return false;
    }
    public boolean is_bool() {
        return false;
    }
    public boolean is_undef() {
        return true;
    }
}
class pBool extends pObject {
    private boolean i;
    public pBool(boolean i) {
        this.i = i;
    }
    public int to_int() {
        if (this.i) {
            return 1;
        }
        else {
            return 0;
        }
    }
    public double to_num() {
        if (this.i) {
            return 1.0;
        }
        else {
            return 0.0;
        }
    }
    public String to_string() {
        if (this.i) {
            return "1";
        }
        else {
            return "";
        }
    }
    public boolean to_bool() {
        return this.i;
    }
    public boolean is_bool() {
        return true;
    }
    public pObject _decr() {
        // --$x
        if (i) {
            return new pInt(0);
        }
        else {
            return new pInt(-1);
        }
    }
    public pObject _incr() {
        // ++$x
        if (i) {
            return new pInt(2);
        }
        else {
            return new pInt(1);
        }
    }
}
class pInt extends pObject {
    private int i;
    public pInt(int i) {
        this.i = i;
    }
    public int to_int() {
        return this.i;
    }
    public double to_num() {
        return (double)(this.i);
    }
    public String to_string() {
        return "" + this.i;
    }
    public boolean to_bool() {
        return this.i != 0;
    }
    public boolean is_int() {
        return true;
    }
    public pObject _decr() {
        // --$x
        return new pInt(i-1);
    }
    public pObject _incr() {
        // ++$x
        return new pInt(i+1);
    }
}
class pNum extends pObject {
    private double i;
    public pNum(double i) {
        this.i = i;
    }
    public int to_int() {
        return (int)(this.i);
    }
    public double to_num() {
        return this.i;
    }
    public String to_string() {
        return "" + this.i;
    }
    public boolean to_bool() {
        return this.i != 0.0;
    }
    public pObject _decr() {
        // --$x
        return new pNum(i-1);
    }
    public pObject _incr() {
        // ++$x
        return new pNum(i+1);
    }
EOT
    . ( join('', map {
            my $perl = $_;
            my $native  = $number_binop{$perl}{op};
            my $returns = $number_binop{$perl}{num_returns};
"    public pObject ${perl}(pObject s) {
        // num - int, num - num
        return new ${returns}( this.i ${native} s.to_num() );
    }
    public pObject ${perl}2(pObject s) {
        // int - num
        return new ${returns}( s.to_num() ${native} this.i );
    }
"
            }
            keys %number_binop ))

    . <<'EOT'
    public boolean is_num() {
        return true;
    }
}
class pString extends pObject {
    private java.lang.String s;
    public pString(String s) {
        this.s = s;
    }
    public pString(char s) {
        this.s = "" + s;
    }
    public int to_int() {
        try {
            return Integer.parseInt(this.s.trim());
        } catch (NumberFormatException nfe) {
            return 0;
        }
    }
    public double to_num() {
        try {
            return Double.parseDouble(this.s.trim());
        } catch (NumberFormatException nfe) {
            return 0.0 + this.to_int();
        }
    }
    public String to_string() {
        return this.s;
    }
    public boolean to_bool() {
        return this.s != ""
            && this.s != "0";
    }
    public boolean is_string() {
        return true;
    }
    public pObject _decr() {
        // --$x
        return this.add(new pInt(-1));
    }
    public pObject _incr() {
        // ++$x
        return pOp.string_increment(this);
    }
EOT
    . ( join('', map {
            my $perl = $_;
            my $native  = $number_binop{$perl}{op};
            my $returns = $number_binop{$perl}{returns};
            my $num_returns = $number_binop{$perl}{num_returns};
            if ($returns eq 'pNum') {
"    public pObject ${perl}(pObject b) {
        // 'num' - int, 'num' - num
        if (this.s.indexOf('.') > -1) {
            return new pNum( this.to_num() ${native} b.to_num() );
        }
        return new pInt( this.to_int() ${native} b.to_int() );
    }
    public pObject ${perl}2(pObject b) {
        // int - 'num'
        if (this.s.indexOf('.') > -1) {
            return new pNum( b.to_num() ${native} this.to_num() );
        }
        return new pInt( b.to_int() ${native} this.to_int() );
    }
"
            }
            else {
"    public pObject ${perl}(pObject b) {
        // 'num' - int, 'num' - num
        if (this.s.indexOf('.') > -1) {
            return new ${num_returns}( this.to_num() ${native} b.to_num() );
        }
        return b.${perl}2(new pInt(this.to_int()));
    }
    public pObject ${perl}2(pObject b) {
        // int - 'num'
        if (this.s.indexOf('.') > -1) {
            return new ${num_returns}( b.to_num() ${native} this.to_num() );
        }
        return new ${returns}( b.to_int() ${native} this.to_int() );
    }
"
            }
            }
            keys %number_binop ))

    . <<'EOT'
}
EOT
        # add "box" classes to Java classes
        # that were declared with
        #
        #   package MyJavaClass { Java }
        #
    . join('', ( map {
                    my $class = $_;
                    my $java_class_name = $class->{java_constructor};
                    my $perl_to_java    = $class->{perl_to_java};
                    my $perl_package    = $class->{perl_package};
                    $class->{import} ? 
"class p${java_class_name} extends pReference {
    public static final pString REF = new pString(\"${perl_package}\");

    private ${java_class_name} stuff;
    // TODO - constructor with Perl parameters
    public p${java_class_name}() {
        this.stuff = new ${java_class_name}();
    }
    public p${java_class_name}(${java_class_name} stuff) {
        this.stuff = stuff;
    }
    public ${java_class_name} ${perl_to_java}() {
        return this.stuff;
    }
    public pObject ref() {
        return REF;
    }
}
" : ()
            }
            values %java_classes
      ))

    . <<'EOT'
// end Perl-Java runtime
EOT

} # end of emit_javascript2()

1;

__END__

=pod

=head1 NAME

Perlito5::Java::Runtime

=head1 DESCRIPTION

Provides runtime routines for the Perlito-in-Java compiled code

=head1 AUTHORS

Flavio Soibelmann Glock

=head1 COPYRIGHT

Copyright 2015 by Flavio Soibelmann Glock.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
