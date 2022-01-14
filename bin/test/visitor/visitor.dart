void main() {
  Student junior = Junior();
  Student senior = Senior();
  Student colleage = Colleage();
  Student adult = Adult();

  CourseVisitor englishVisitor = EnglishVisitor();
  CourseVisitor gymVisitor = GymVisitor();
  CourseVisitor geographyVisitor = GeographyVisitor();

  junior.accept(englishVisitor);
  junior.accept(gymVisitor);
  junior.accept(geographyVisitor);

  senior.accept(englishVisitor);
  senior.accept(gymVisitor);
  senior.accept(geographyVisitor);

  colleage.accept(englishVisitor);
  colleage.accept(gymVisitor);
  colleage.accept(geographyVisitor);

  adult.accept(englishVisitor);
  adult.accept(gymVisitor);
  adult.accept(geographyVisitor);
}

abstract class Student {
  accept(CourseVisitor visitor);
}

class Junior extends Student {
  @override
  accept(CourseVisitor visitor) {
    return visitor.visitJunior(this);
  }
}

class Senior extends Student {
  @override
  accept(CourseVisitor visitor) {
    return visitor.visitSenior(this);
  }
}

class Colleage extends Student {
  @override
  accept(CourseVisitor visitor) {
    return visitor.visitColleage(this);
  }
}

class Adult extends Student {
  @override
  accept(CourseVisitor visitor) {
    return visitor.visitAdult(this);
  }
}

abstract class CourseVisitor {
  visitJunior(Junior junior);
  visitSenior(Senior senior);
  visitColleage(Colleage colleage);
  visitAdult(Adult adult);
}

class EnglishVisitor extends CourseVisitor {
  @override
  visitColleage(Colleage colleage) {}

  @override
  visitJunior(Junior junior) {
    print('junior english');
  }

  @override
  visitSenior(Senior senior) {
    print('senior english');
  }

  @override
  visitAdult(Adult adult) {
    print('adult literature');
  }
}

class GymVisitor extends CourseVisitor {
  @override
  visitColleage(Colleage colleage) {
    print('extreme sprots');
  }

  @override
  visitJunior(Junior junior) {
    print('running/swimming');
  }

  @override
  visitSenior(Senior senior) {
    print('basketball/football');
  }

  @override
  visitAdult(Adult adult) {
    print('marathon');
  }
}

class GeographyVisitor extends CourseVisitor {
  @override
  visitColleage(Colleage colleage) {
    print('universe geography');
  }

  @override
  visitJunior(Junior junior) {
    print('world geography');
  }

  @override
  visitSenior(Senior senior) {
    print('country geography');
  }

  @override
  visitAdult(Adult adult) {
    print('heart of earth');
  }
}
