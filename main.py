# input ->  [7,1,5,3,6,4, 56, 64, 677, 657, 67]
 
# output -> {1: [7, 1, 5, 3, 6, 4], 2: [56, 64, 67], 3: [677, 657]}


input =  [7,1,5,3,6,4, 56, 64, 677, 657, 67]

output = {}
for i in input:
    size = len(str(i))
    if size not in output:
        new = []
        output[size] = size
        output.values += i
        new.append(i)
    else:
       
print(output)
    
    
    



        
    

