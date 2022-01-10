void main() {
  ///           op1   op2   op3   op4
  ///   class1
  ///   class2
  ///   class3

  /// 1. 每行各自一个类，方法各自取名实现，具体解析时，使用switch/case来判断类的类型
  /// pros: 最简单直接
  /// cons: 匹配效率低
  ///
  ///
  /// 2. 每一行都是基类的子类，把所有的op作为每个类的方法
  /// pros: 添加新row，非常简单，添加一个新类，实现所有方法即可
  /// cons: 添加新column, 基类添加一个新方法，所有的字类都得重写
  ///
  ///
  /// 3. 每一列都对应一个函数，传入类，判断子类类型
  /// pros: 新加列很简单，匹配所有子类类型即可
  /// cons: 添加新row, 也就是添加一个字类，那么所有的函数都得完善匹配内容
  ///
  ///
  /// 4. 参观者模式: Visitor Pattern
  /// 所有的Visitor继承同一个基类，本基类的方法对应于行，一行一个方法。此时列就表示成了一种Visitor

  BaseClass class1 = Class1();
  BaseClass class2 = Class2();
  BaseClass class3 = Class3();

  Visitor<int> visitorA = VisitorA();
  Visitor<double> visitorB = VisitorB();
  Visitor<String> visitorC = VisitorC();
}

abstract class Visitor<R> {
  R visitClass1(Class1 class1);
  R visitClass2(Class2 class2);
  R visitClass3(Class3 class2);
}

class VisitorA extends Visitor<int> {
  @override
  int visitClass1(Class1 class1) {
    // TODO: implement visitClass1
    throw UnimplementedError();
  }

  @override
  int visitClass2(class2) {
    // TODO: implement visitClass2
    throw UnimplementedError();
  }

  @override
  int visitClass3(class2) {
    // TODO: implement visitClass3
    throw UnimplementedError();
  }
}

class VisitorB extends Visitor<double> {
  @override
  double visitClass1(Class1 class1) {
    // TODO: implement visitClass1
    throw UnimplementedError();
  }

  @override
  double visitClass2(Class2 class2) {
    // TODO: implement visitClass2
    throw UnimplementedError();
  }

  @override
  double visitClass3(Class3 class2) {
    // TODO: implement visitClass3
    throw UnimplementedError();
  }
}

class VisitorC extends Visitor<String> {
  @override
  String visitClass1(Class1 class1) {
    // TODO: implement visitClass1
    throw UnimplementedError();
  }

  @override
  String visitClass2(Class2 class2) {
    // TODO: implement visitClass2
    throw UnimplementedError();
  }

  @override
  String visitClass3(Class3 class2) {
    // TODO: implement visitClass3
    throw UnimplementedError();
  }
}

abstract class BaseClass {
  R accept<R>(Visitor<R> visitor);
}

class Class1 extends BaseClass {
  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitClass1(this);
  }
}

class Class2 extends BaseClass {
  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitClass2(this);
  }
}

class Class3 extends BaseClass {
  @override
  R accept<R>(Visitor<R> visitor) {
    return visitor.visitClass3(this);
  }
}
