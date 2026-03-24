[1mdiff --git a/emp.py b/emp.py[m
[1mindex 92662a8..6a8ec36 100644[m
[1m--- a/emp.py[m
[1m+++ b/emp.py[m
[36m@@ -1,82 +1,121 @@[m
 import json[m
[32m+[m
 class Employee:[m
[31m-    def __init__(self,emp_id,name,salary):[m
[31m-        self.emp_Detail = [][m
[31m-        [m
[32m+[m[32m    def __init__(self, emp_id, name, salary):[m
[32m+[m[32m        if salary < 0:[m[41m   [m
[32m+[m[32m            raise ValueError("Salary cannot be negative")[m
 [m
[31m-        try:[m
[31m-            self.emp_id = emp_id[m
[31m-            self.name = name[m
[31m-            self.salary = salary[m
[31m-            if self.salary < 0:[m
[31m-                raise ValueError[m
[31m-        except:[m
[31m-            self.emp_id = emp_id[m
[31m-            self.name = name[m
[31m-            self.salary = salary[m
[31m-            self.emp_Detail.append(self.emp_id,self.name,self.salary)[m
[32m+[m[32m        self.emp_id = emp_id[m
[32m+[m[32m        self.name = name[m
[32m+[m[32m        self.salary = salary[m
 [m
     def display_details(self):[m
[31m-        print(f'the employee name is {self.name} ,id is {self.emp_id}  and salary is {self.salary}')[m
[32m+[m[32m        print(f'Name: {self.name}, ID: {self.emp_id}, Salary: {self.salary}')[m
[32m+[m
 [m
 class manager(Employee):[m
[31m-    def __init__(self,size):[m
[32m+[m[32m    def __init__(self, emp_id, name, salary, size):[m[41m   [m
[32m+[m[32m        super().__init__(emp_id, name, salary)[m
         self.size = size[m
[31m-    def display_details(self):[m
[31m-        print(f'the employee name is {self.name} ,id is {self.emp_id}  and salary is {self.salary} the team size if f{self.size}')[m
 [m
[31m-    with open('emp_details.json','w') as save_emp:[m
[31m-        json.dump(save_emp)[m
[32m+[m[32m    def display_details(self):[m
[32m+[m[32m        super().display_details()[m
[32m+[m[32m        print(f'Team size: {self.size}')[m
 [m
 [m
 class developer(Employee):[m
[31m-    def __init__(self,lang):[m
[32m+[m[32m    def __init__(self, emp_id, name, salary, lang):[m[41m   [m
[32m+[m[32m        super().__init__(emp_id, name, salary)[m
         self.lang = lang[m
[31m-    [m
[32m+[m
     def display_details(self):[m
[31m-        print(f'he employee name is {self.name} ,id is {self.emp_id}  and salary is {self.salary} the programming langunge is {self.lang}')[m
[32m+[m[32m        super().display_details()[m
[32m+[m[32m        print(f'Language: {self.lang}')[m
[32m+[m
 [m
 class EmployeeManager:[m
 [m
[31m-    def __init__(self,id):[m
[31m-        self.id = id[m
[31m-[m
[31m-    def add_employee(self):[m
[31m-        if self.id == self.emp_id:[m
[31m-            self.emp_list.append(self.id)[m
[31m-        else:[m
[31m-            raise ValueError[m
[31m-    [m
[31m-    def remove_employee(self):[m
[31m-        if self.id == self.emp_id:[m
[31m-            self.emp_list.remove(self.id)[m
[31m-        else:[m
[31m-            raise ValueError[m
[31m-    [m
[31m-    def get_employee(self):[m
[31m-        if self.id  == self.emp_id:[m
[31m-            return self.id[m
[31m-        else:[m
[31m-            raise ValueError[m
[31m-        [m
[32m+[m[32m    def __init__(self):[m
[32m+[m[32m        self.emp_list = [][m[41m   [m
[32m+[m
[32m+[m[32m    def add_employee(self, emp):[m[41m   [m
[32m+[m[32m        for e in self.emp_list:[m
[32m+[m[32m            if e.emp_id == emp.emp_id:[m
[32m+[m[32m                raise ValueError("Duplicate ID")[m
[32m+[m[32m        self.emp_list.append(emp)[m
[32m+[m
[32m+[m[32m    def remove_employee(self, emp_id):[m[41m  [m
[32m+[m[32m        for e in self.emp_list:[m
[32m+[m[32m            if e.emp_id == emp_id:[m
[32m+[m[32m                self.emp_list.remove(e)[m
[32m+[m[32m                return[m
[32m+[m[32m        raise KeyError("Employee not found")[m
[32m+[m
[32m+[m[32m    def get_employee(self, emp_id):[m[41m   [m
[32m+[m[32m        for e in self.emp_list:[m
[32m+[m[32m            if e.emp_id == emp_id:[m
[32m+[m[32m                return e[m
[32m+[m[32m        raise KeyError("Employee not found")[m
[32m+[m
     def display_all(self):[m
[32m+[m[32m        if not self.emp_list:[m
[32m+[m[32m            print("No employees")[m
[32m+[m[32m        for e in self.emp_list:[m
[32m+[m[32m            e.display_details()[m
 [m
[31m-        if len(self.emp_Details) > 0:[m
[31m-            print(f' the details of employees are {self.emp_Details}')[m
[31m-        else:[m
[31m-            print(' the list is empty')[m
[31m-        [m
[31m-    def load(self):[m
[32m+[m[32m    def save(self):[m[41m   [m
[32m+[m[32m        data = [][m
[32m+[m[32m        for e in self.emp_list:[m
[32m+[m[32m            if isinstance(e, manager):[m
[32m+[m[32m                data.append({"type": "Manager", "emp_id": e.emp_id, "name": e.name, "salary": e.salary, "size": e.size})[m
[32m+[m[32m            else:[m
[32m+[m[32m                data.append({"type": "Developer", "emp_id": e.emp_id, "name": e.name, "salary": e.salary, "lang": e.lang})[m
[32m+[m
[32m+[m[32m        with open('employees.json', 'w') as f:[m
[32m+[m[32m            json.dump(data, f)[m
[32m+[m
[32m+[m[32m    def load(self):[m[41m  [m
         try:[m
[31m-            with open('emp_details.json','r') as read:[m
[31m-                json.dump(read)[m
[32m+[m[32m            with open('employees.json', 'r') as f:[m
[32m+[m[32m                data = json.load(f)[m
[32m+[m
[32m+[m[32m            for d in data:[m
[32m+[m[32m                if d["type"] == "Manager":[m
[32m+[m[32m                    self.emp_list.append(manager(d["emp_id"], d["name"], d["salary"], d["size"]))[m
[32m+[m[32m                else:[m
[32m+[m[32m                    self.emp_list.append(developer(d["emp_id"], d["name"], d["salary"], d["lang"]))[m
         except:[m
[31m-            pass[m
[32m+[m[32m            self.emp_list = [][m
[32m+[m
[32m+[m
[32m+[m
[32m+[m[32mif __name__ == "__main__":[m[41m   [m
[32m+[m
[32m+[m[32m    em = EmployeeManager()[m
[32m+[m
[32m+[m[32m    m1 = manager(1, "A", 50000, 5)[m
[32m+[m[32m    m2 = manager(2, "B", 60000, 3)[m
[32m+[m
[32m+[m[32m    d1 = developer(3, "C", 40000, "Python")[m
[32m+[m[32m    d2 = developer(4, "D", 45000, "Java")[m
[32m+[m
[32m+[m[32m    em.add_employee(m1)[m
[32m+[m[32m    em.add_employee(m2)[m
[32m+[m[32m    em.add_employee(d1)[m
[32m+[m[32m    em.add_employee(d2)[m
[32m+[m
[32m+[m[32m    em.save()[m
 [m
[31m-obj1 = manager(4)[m
[31m-obj2 = manager(3)[m
[32m+[m[32m    em2 = EmployeeManager()[m
[32m+[m[32m    em2.load()[m
[32m+[m[32m    em2.display_all()[m
 [m
[31m-dev1 = developer('')[m
[31m-    [m
[32m+[m[32m    try:[m
[32m+[m[32m        em.add_employee(m1)[m
[32m+[m[32m    except ValueError as e:[m
[32m+[m[32m        print(e)[m
 [m
[31m-    [m
\ No newline at end of file[m
[32m+[m[32m    try:[m
[32m+[m[32m        em.remove_employee(10)[m
[32m+[m[32m    except KeyError as e:[m
[32m+[m[32m        print(e)[m
\ No newline at end of file[m
