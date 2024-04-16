CHUNK_SIZE = 1000

def sort_big_data(data_array):
    i = 0

    while i < len(data_array):
        chunk = data_array[i:min(i+CHUNK_SIZE, len(data_array))]
        i += CHUNK_SIZE



