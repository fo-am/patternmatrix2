def convert_4bit(arr):
    # clockwise from top left
    return arr[0]|arr[1]<<1|arr[3]<<2|arr[2]<<3

## this classifier is simply a filter for biasing against readings
## for different tokens in favour of orientations of existing ones
## noise is considered to be caused primarily by 'in between' sensor
## readings of the tangible tokens

class sensor_filter:
    def __init__(self,tokens):
        self.token_current = "?"
        self.token_theory = "?"
        self.value_current = 0
        self.value_theory = 0
        self.confidence_time = 0
        self.token_change_time = 1.0
        self.token_orient_time = 0.1
        # convert to integer representation
        self.tokens = self.convert_tokens(tokens)

    def convert_token(self,patterns):
        return map(convert_4bit,patterns)

    def convert_tokens(self,tokens):
        return {k: self.convert_token(v) for k, v in tokens.items()}

    def value_to_token(self,val):
        for k,v in self.tokens.items():
            if val in v: return k
        return "?"

    def observation(self,dt,value):
        # have we witnessed a change?
        if value != self.value_theory:
            self.value_theory = value
            self.token_theory = self.value_to_token(value)
            if self.token_current in self.tokens and \
               value in self.tokens[self.token_current]:
                # permutation of the current token is more likely
                self.confidence_time += self.token_orient_time
            else:
                # than a new token (could be rotation noise etc)
                self.confidence_time += self.token_change_time
            
        if self.confidence_time==0:
            self.token_current=self.token_theory
            self.value_current=self.value_theory
            self.confidence_time=0
        else:
            self.confidence_time=max(0,self.confidence_time-dt)


class sensor_grid:
    def __init__(self, num_sensors, layout, tokens):
        self.state = []
        for i in range(0,num_sensors):
            self.state.append(sensor_filter(tokens))
        self.layout = layout
            
    def update(self, dt,address,data_a,data_b):
        # i2c 20,21,22,23,24,25,26

        # sensor pin out:
        # A: 1 2 3 4 5 6 7 8
        # B: 1 2 3 4 5 6 7 8

        sensor_data=[]
        for i in range(0,4):
            # convert to clockwise
            # b1,a2,a1,b2...
            off = i*2
            sensor_data.append([data_b[off],data_a[off+1],
                                data_a[off],data_b[off+1]])
            
        # search layout and update filters
        for i,p in enumerate(self.layout):
            if p[0]==address:
                self.state[i].observation(dt,convert_4bit(sensor_data[p[1]]))


