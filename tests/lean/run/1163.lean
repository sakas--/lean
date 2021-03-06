inductive Foo : Type → Type*
| mk     : Π (X : Type), Foo X
| wrap   : Π (X : Type), Foo X → Foo X

def rig : Π {X : Type}, Foo X → Foo X
| X (Foo.wrap .X foo)  := foo
| X foo                := foo
