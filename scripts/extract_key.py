import sys
import base64

def get_key(fileName):
    try:
        with open(fileName, "rb") as file:
            file.seek(-64, 2)
            readed_bytes = file.read()
            size = len(readed_bytes)
            if size == 64:
                x = readed_bytes[:32]
                y = readed_bytes[32:]
                x_base64 = base64.b64encode(x).decode('utf-8')
                y_base64 = base64.b64encode(y).decode('utf-8')
                return x_base64, y_base64
            else:
                return None, None
    except FileNotFoundError:
        print(f"O arquivo '{fileName}' não foi encontrado.")
    except Exception as e:
        print(f"Ocorreu um erro: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Uso: python key.py <file_name>")
        sys.exit(1)
    
    file_name = sys.argv[1]
    x_base64, y_base64 = get_key(file_name)
    if x_base64 and y_base64:
        print(f"x em Base64: {x_base64}")
        print(f"y em Base64: {y_base64}")
    else:
        print("O arquivo não possui pelo menos 64 bytes.")

