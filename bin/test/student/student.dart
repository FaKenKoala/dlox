void main() {
  Student junior = Junior();
  Student senior = Senior();
  Student colleage = Colleage();
  Student adult = Adult();

  junior.englishCourse();
  junior.geographyCourse();
  junior.gymCourse();

  senior.englishCourse();
  senior.geographyCourse();
  senior.gymCourse();

  colleage.englishCourse();
  colleage.geographyCourse();
  colleage.gymCourse();

  adult.englishCourse();
  adult.geographyCourse();
  adult.gymCourse();
}

abstract class Student {
  gymCourse();
  englishCourse();
  geographyCourse();

  /// 新增数学课程
  mathCourse();
}

class Junior extends Student {
  @override
  englishCourse() {
    print('junior english');
  }

  @override
  geographyCourse() {
    print('country geography');
  }

  @override
  gymCourse() {
    print('running/swimming');
  }

  @override
  mathCourse() {
    print('1+1');
  }
}

class Senior extends Student {
  @override
  englishCourse() {
    print("senior english");
  }

  @override
  geographyCourse() {
    print("world geography");
  }

  @override
  gymCourse() {
    print("basketball/football");
  }

  @override
  mathCourse() {
    print('1*1');
  }
}

class Colleage extends Student {
  @override
  englishCourse() {
    print("colleage english");
  }

  @override
  geographyCourse() {
    print("universe geography");
  }

  @override
  gymCourse() {
    print("extreme sports");
  }

  @override
  mathCourse() {
    print('set theory');
  }
}

/// 新增成人学生
class Adult extends Student {
  @override
  englishCourse() {
    print('adult literature');
  }

  @override
  geographyCourse() {
    print('heart of earth');
  }

  @override
  gymCourse() {
    print('marathon');
  }

  @override
  mathCourse() {
    print('category theory');
  }
}
