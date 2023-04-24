import numpy as np

def hex_to_ndarray(hex,length):
    hex = bin(hex)[2:].zfill(length)[::-1]
    return np.asarray([int(i) for i in hex], dtype=np.int8)

def ndarray_to_hex(ndarray):
    s = ""
    for i in range(ndarray.size):
        s = s + str(ndarray[i])
    return hex(int(s[::-1], 2))


def convert(s):
    l = len(s)/2
    n = ""
    s = s[::-1]
    for i in range(int(l)):
        n = n + s[2*i:2*i+2][::-1]
    return int(n, 16)


class Grain128:
    def __init__(self,key,iv) -> None:
        self.lsfr = np.zeros(128,dtype=np.uint8)
        self.nsfr = np.zeros(128,dtype=np.uint8)
        self.key = key
        self.iv = iv
        self.nsfr = hex_to_ndarray(key,128)
        self.lsfr = np.concatenate((np.atleast_1d(hex_to_ndarray(iv,96)),np.ones(32,dtype=np.uint8)))
    
    def _reset(self) -> None:
        self.nsfr = hex_to_ndarray(self.key,128)
        self.lsfr = np.concatenate((np.atleast_1d(hex_to_ndarray(self.iv,96)),np.ones(32,dtype=np.uint8)))

    def _calculate(self):
        s = self.lsfr
        b = self.nsfr

        f = s[0] ^ s[7] ^ s[38] ^ s[70] ^ s[81] ^ s[96]
 
        g = b[0] ^ b[26] ^ b[56] ^ b[91] ^ b[96] ^ (b[3] & b[67]) ^ (b[11] & b[13]) ^ (b[17] & b[18]) ^ (b[27] & b[59]) ^ (b[40] & b[48]) ^ (b[61] & b[65]) ^ (b[68] & b[84])

        h = (b[12] & s[8]) ^ (s[13] & s[20]) ^ (b[95] & s[42]) ^ (s[60] & s[79]) ^ (b[12] & s[95] & b[95])

        y = h ^ s[93] ^ b[2] ^ b[15] ^ b[36] ^ b[45] ^ b[64] ^b[73] ^ b[89]

        return f,g,h,y
    
    def _initiate(self): 
        self._reset()  
        for i in range(256):
            f,g,h,y = self._calculate()
            lfb = y ^ f
            nfb = y ^ g ^ self.lsfr[0]
            self.lsfr = np.roll(self.lsfr,-1)
            self.nsfr = np.roll(self.nsfr,-1)
            self.lsfr[127] = lfb
            self.nsfr[127] = nfb

    def _generate(self,l):
        self._initiate()
        keystream = np.zeros(l,dtype=np.uint8)
        for i in range(l):
            f,g,h,y = self._calculate()
            lfb =  f
            nfb =  g ^ self.lsfr[0]
            self.lsfr = np.roll(self.lsfr,-1)
            self.nsfr = np.roll(self.nsfr,-1)
            self.lsfr[127] = lfb
            self.nsfr[127] = nfb
            keystream[i] = y
        return keystream
    
    def _generate_byte(self,bl):
        bys = []
        self._initiate()
        for j in range(bl):
            keystream = np.zeros(8,dtype=np.uint8)
            for i in range(8):
                f,g,h,y = self._calculate()
                lfb =  f
                nfb =  g ^ self.lsfr[0]
                self.lsfr = np.roll(self.lsfr,-1)
                self.nsfr = np.roll(self.nsfr,-1)
                self.lsfr[127] = lfb
                self.nsfr[127] = nfb
                keystream[i] = y
            bys.append(ndarray_to_hex(keystream))
        return bys
    
    def encrypt(self, input: str) -> str:
        """
        Encrypt the input
        """
        input_bytes = bytes(input, "utf-8")
        l = len(input_bytes) * 8
        key_stream = self._generate(l)
        key_stream = ndarray_to_hex(key_stream)
        cipher = int(key_stream, 16) ^ int.from_bytes(input_bytes, "big")

        cipher_text = bytes.fromhex(hex(cipher)[2:])
        return cipher_text

    def decrypt(self, cipher_text: bytes) -> str:
        """
        Decrypt the cipher text
        """
        l = len(cipher_text) * 8
        key_stream = self._generate(l)
        key_stream = ndarray_to_hex(key_stream)
        plain = int(key_stream, 16) ^ int.from_bytes(cipher_text, "big")

        plain_text = bytes.fromhex(hex(plain)[2:])
        return plain_text




def main():
    # iv = convert("000000000000000000000000")
    # key = convert("00000000000000000000000000000000")

    iv = convert("0123456789abcdef12345678")
    key = convert("0123456789abcdef123456789abcdef0")
    l = 128
    grain = Grain128(key,iv)
    keystream = grain._generate(l)
    print("Keystream: ")
    print(ndarray_to_hex(keystream))
    asbytes = grain._generate_byte(16)
    print("Keystream as bytes: ")
    print(asbytes)
    print("\n")
    test = "Hello World"
    print("Plain text: ")
    print(test)
    cipher = grain.encrypt(test)
    print("Cipher: ")
    print(cipher)
    print("Plain: ")
    print(grain.decrypt(cipher))

if __name__ == "__main__":
    main()
