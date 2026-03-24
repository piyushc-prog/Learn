import json
import psycopg2

def get_db():
    return psycopg2.connect(
        host = '',
        database = '',
        user = '',
        password = '',
        port  = ''
    )
class Employee:
    def __init__(self,emp_id,name,salary):
        self.emp_id = emp_id
        self.name = name
        self.salary = salary
        if self.salary < 0: raise ValueError("Negative salary")

    def display_details(self):
        print(f'the employee name is {self.name} ,id is {self.emp_id} and salary is {self.salary}')

class manager(Employee):
    def __init__(self,emp_id,name,salary,size):
        super().__init__(emp_id, name, salary)
        self.size = size
    def display_details(self):
        print(f'the employee name is {self.name} ,id is {self.emp_id} and salary is {self.salary} the team size is {self.size}')

class developer(Employee):
    def __init__(self,emp_id,name,salary,lang):
        super().__init__(emp_id, name, salary)
        self.lang = lang
    
    def display_details(self):
        print(f'the employee name is {self.name} ,id is {self.emp_id} and salary is {self.salary} the programming language is {self.lang}')

class EmployeeManager:
    def __init__(self):
        self.employees = []

    def add_employee(self,emp):
        for e in self.employees:
            if e.emp_id == emp.emp_id: raise ValueError("Duplicate ID")
        self.employees.append(emp)
    
    def remove_employee(self,emp_id):
        self.employees.remove(self.get_employee(emp_id))
    
    def get_employee(self,emp_id):
        for e in self.employees:
            if e.emp_id == emp_id: return e
        raise KeyError("Employee not found")
        
    def display_all(self):
        if len(self.employees) > 0:
            for e in self.employees: e.display_details()
        else:
            print('the list is empty')
        
    def load(self):
        try:
            with open('emp_details.json','r') as read:
                data = json.load(read)
            self.employees = []
            for d in data:
                if d.get('type') == 'manager':
                    self.employees.append(manager(**d))
                else:
                    self.employees.append(developer(**d))
        except:
            pass
    
    def save(self):
        data = []
        for e in self.employees:
            d = {
                'emp_id':e.emp_id,
                'name':e.name,
                'salary':e.salary,
                'type':e.__class__.__name__
            }
            if hasattr(e,'size'): d['size'] = e.size
            if hasattr(e,'lang'): d['lang'] = e.lang
            data.append(d)
        with open('emp_details.json','w') as f: json.dump(data, f)

if __name__ == "__main__":
    em = EmployeeManager()
    em.add_employee(manager(1,"Aman",10300,5))
    em.add_employee(developer(2,"Naman",12800,"Py"))
    em.display_all()
    em.save()
    em2 = EmployeeManager()
    em2.load()
    em2.display_all()
