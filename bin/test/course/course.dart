void main() {
  Course englishCourse = EnglishCourse();
  Course geographyCourse = GeographyCourse();
  Course gymCourse = GymCourse();

  englishCourse.juniorStudent();
  englishCourse.seniorStudent();
  englishCourse.colleageStudent();
  englishCourse.adultStudent();

  geographyCourse.juniorStudent();
  geographyCourse.seniorStudent();
  geographyCourse.colleageStudent();
  geographyCourse.adultStudent();

  gymCourse.juniorStudent();
  gymCourse.seniorStudent();
  gymCourse.colleageStudent();
  gymCourse.adultStudent();
}

abstract class Course {
  juniorStudent();
  seniorStudent();
  colleageStudent();

  /// 新增成人
  adultStudent();
}

class EnglishCourse extends Course {
  @override
  colleageStudent() {
    print('colleage english');
  }

  @override
  juniorStudent() {
    print('junior english');
  }

  @override
  seniorStudent() {
    print('senior english');
  }

  @override
  adultStudent() {
    print('adult literature');
  }
}

class GeographyCourse extends Course {
  @override
  colleageStudent() {
    print('universe geography');
  }

  @override
  juniorStudent() {
    print('world geography');
  }

  @override
  seniorStudent() {
    print('country geography');
  }

  @override
  adultStudent() {
    print('heart of earth');
  }
}

class GymCourse extends Course {
  @override
  colleageStudent() {
    print('extreme sports');
  }

  @override
  juniorStudent() {
    print('running/swimming');
  }

  @override
  seniorStudent() {
    print('basketball/football');
  }

  @override
  adultStudent() {
    print('marathon');
  }
}

class MathCourse extends Course {
  @override
  adultStudent() {
    print('category theory');
  }

  @override
  colleageStudent() {
    print('set theory');
  }

  @override
  juniorStudent() {
    print('1+1');
  }

  @override
  seniorStudent() {
    print('1*1');
  }
}
