import json
class Employee:
    def __init__(self,emp_id,name,salary):
        self.emp_Detail = []
        

        try:
            self.emp_id = emp_id
            self.name = name
            self.salary = salary
            if self.salary < 0:
                raise ValueError
        except:
            self.emp_id = emp_id
            self.name = name
            self.salary = salary
            self.emp_Detail.append(self.emp_id,self.name,self.salary)

    def display_details(self):
        print(f'the employee name is {self.name} ,id is {self.emp_id}  and salary is {self.salary}')

class manager(Employee):
    def __init__(self,size):
        self.size = size
    def display_details(self):
        print(f'the employee name is {self.name} ,id is {self.emp_id}  and salary is {self.salary} the team size if f{self.size}')

    with open('emp_details.json','w') as save_emp:
        json.dump(save_emp)


class developer(Employee):
    def __init__(self,lang):
        self.lang = lang
    
    def display_details(self):
        print(f'he employee name is {self.name} ,id is {self.emp_id}  and salary is {self.salary} the programming langunge is {self.lang}')

class EmployeeManager:

    def __init__(self,id):
        self.id = id

    def add_employee(self):
        if self.id == self.emp_id:
            self.emp_list.append(self.id)
        else:
            raise ValueError
    
    def remove_employee(self):
        if self.id == self.emp_id:
            self.emp_list.remove(self.id)
        else:
            raise ValueError
    
    def get_employee(self):
        if self.id  == self.emp_id:
            return self.id
        else:
            raise ValueError
        
    def display_all(self):

        if len(self.emp_Details) > 0:
            print(f' the details of employees are {self.emp_Details}')
        else:
            print(' the list is empty')
        
    def load(self):
        try:
            with open('emp_details.json','r') as read:
                json.dump(read)
        except:
            pass

obj1 = manager(4)
obj2 = manager(3)

dev1 = developer('')
    

    