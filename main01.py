"""
    Implementation of Grain-128 Encryption Algorithm
"""

import numpy as np


class LFSR:
    """
    Linear Feedback Shift Register
    """

    def __init__(self, iv: int) -> None:
        """
        Initialize the LFSR with the IV

        iv : The 96-bit initialization vector as integer
        """
        self.REGISTER = np.zeros(128, dtype=np.int8)
        iv = bin(iv)[2:].zfill(96)[::-1]
        self.IV = np.asarray([int(i) for i in iv], dtype=np.int8)
        self.REGISTER[0:96] = self.IV
        self.REGISTER[96:128] = np.ones(32, dtype=np.int8)
        self.OUTPUT = 0
    

    def __repr__(self) -> str:
        s = ""
        for i in range(128):
            s = s + str(self.REGISTER[i])
        return hex(int(s[::-1], 2))

    def _update(self, output,mode) -> None:
        """
        Update the LFSR using its feedback polynomial
        """
        feedback = self._feedback()
        self.OUTPUT = self.REGISTER[0]
        self.REGISTER = np.roll(self.REGISTER, -1)
        if mode == 0:
            self.REGISTER[127] = feedback ^ output
        else:
            self.REGISTER[127] = feedback
    def _feedback(self) -> int:
        """
        Return the feedback calculated using the LFSR's feedback polynomial
        """
        """
            Feedback polynomial:
            s(i+128) = s(i) + s(i+7) + s(i+38) + s(i+70) + s(i+81) + s(i+96)
        """
        si0 = self.REGISTER[0]
        si7 = self.REGISTER[7]
        si38 = self.REGISTER[38]
        si70 = self.REGISTER[70]
        si81 = self.REGISTER[81]
        si96 = self.REGISTER[96]
        feedback = si0 ^ si7 ^ si38 ^ si70 ^ si81 ^ si96
        return feedback


class NFSR:
    """
    Non - Linear Feedback Shift Register
    """

    def __init__(self, key: int) -> None:
        """
        Initialize the NFSR with the Key

        key : The 128-bit Key as integer
        """
        self.REGISTER = np.zeros(128, dtype=np.int8)
        key = bin(key)[2:].zfill(128)[::-1]
        self.KEY = np.asarray([int(i) for i in key], dtype=np.int8)
        self.REGISTER = self.KEY
        self.OUTPUT = 0

    def __repr__(self) -> str:
        s = ""
        for i in range(128):
            s = s + str(self.REGISTER[i])
        return hex(int(s[::-1], 2))

    def _update(self, si0, output,mode) -> None:
        """
        Update the NFSR using its feedback polynomial
        """
        feedback = self._feedback(si0)
        self.OUTPUT = self.REGISTER[0]
        self.REGISTER = np.roll(self.REGISTER, -1)
        if mode == 0:
            self.REGISTER[127] = feedback ^ output
        else:
            self.REGISTER[127] = feedback

    def _feedback(self, si0) -> int:
        """
        Return the feedback calculated using the NFSR's feedback polynomial
        """
        """
            Feedback polynomial:
            b(i+128) = s(i) + b(i) + b(i+26) + b(i+56) + b(i+91) + b(i+96) + b(i+3)*b(i+67) + b(i+11)*b(i+13) + b(i+17)*b(i+18) + b(i+27)*b(i+59) + b(i+40)*b(i+48) + b(i+61)*b(i+65) + b(i+68)*b(i+84)
        """
        bi0 = self.REGISTER[0]
        bi26 = self.REGISTER[26]
        bi56 = self.REGISTER[56]
        bi91 = self.REGISTER[91]
        bi96 = self.REGISTER[96]
        bi3 = self.REGISTER[3]
        bi67 = self.REGISTER[67]
        bi11 = self.REGISTER[11]
        bi13 = self.REGISTER[13]
        bi17 = self.REGISTER[17]
        bi18 = self.REGISTER[18]
        bi27 = self.REGISTER[27]
        bi59 = self.REGISTER[59]
        bi40 = self.REGISTER[40]
        bi48 = self.REGISTER[48]
        bi61 = self.REGISTER[61]
        bi65 = self.REGISTER[65]
        bi68 = self.REGISTER[68]
        bi84 = self.REGISTER[84]

        feedback = (
            si0
            ^ bi0
            ^ bi26
            ^ bi56
            ^ bi91
            ^ bi96
            ^ (bi3 & bi67)
            ^ (bi11 & bi13)
            ^ (bi17 & bi18)
            ^ (bi27 & bi59)
            ^ (bi40 & bi48)
            ^ (bi61 & bi65)
            ^ (bi68 & bi84)
        )
        return feedback


class Grain128:
    """
    Grain-128 Encryption Algorithm
    """

    def __init__(self, key: int, iv: int) -> None:
        self.KEY = key
        self.IV = iv
        self.LFSR = LFSR(self.IV)
        self.NFSR = NFSR(self.KEY)

    def _reset(self) -> None:
        """
        Reset the LFSR and NFSR
        """
        self.LFSR = LFSR(self.IV)
        self.NFSR = NFSR(self.KEY)

    def _update(self,mode) -> None:
        """
        Update the LFSR and NFSR
        
        mode = 0 for initialization

        mode = 1 for keystream generation
        """


        self.NFSR._update(self.LFSR.REGISTER[0], self._output(),mode)
        self.LFSR._update(self._output(),mode)

    def _initiate(self) -> None:
        """
        Initiate the LFSR and NFSR
        """
        for i in range(256):
            self._update(0)

    def _output(self) -> int:
        """
        Return the output bit
        """
        """
        h(x) = x0x1 + x2x3 + x4x5 + x6x7 + x0x4x8

        b(i+12), s(i+8), s(i+13), s(i+20),b(i+95), s(i+42), s(i+60), s(i+79) and s(i+95)
        """
        x0 = self.NFSR.REGISTER[12]
        x1 = self.LFSR.REGISTER[8]
        x2 = self.LFSR.REGISTER[13]
        x3 = self.LFSR.REGISTER[20]
        x4 = self.NFSR.REGISTER[95]
        x5 = self.LFSR.REGISTER[42]
        x6 = self.LFSR.REGISTER[60]
        x7 = self.LFSR.REGISTER[79]
        x8 = self.LFSR.REGISTER[95]

        h = (x0 & x1) ^ (x2 & x3) ^ (x4 & x5) ^ (x6 & x7) ^ (x0 & x4 & x8)

        si93 = self.LFSR.REGISTER[93]

        """
        {2, 15, 36, 45, 64, 73, 89}
        """

        bi2 = self.NFSR.REGISTER[2]
        bi15 = self.NFSR.REGISTER[15]
        bi36 = self.NFSR.REGISTER[36]
        bi45 = self.NFSR.REGISTER[45]
        bi64 = self.NFSR.REGISTER[64]
        bi73 = self.NFSR.REGISTER[73]
        bi89 = self.NFSR.REGISTER[89]

        output = h ^ si93 ^ bi2 ^ bi15 ^ bi36 ^ bi45 ^ bi64 ^ bi73 ^ bi89

        return output

    def _generate(self, l: int) -> int:
        """
        Generate the key stream bit
        """
        self._reset()
        self._initiate()
        key_stream = ""
        for i in range(l):
            key_stream = key_stream + str(self._output())
            self._update(1)
        # print(bin(int(key_stream[::-1], 2)))
        return hex(int(key_stream, 2))

    def encrypt(self, input: str) -> str:
        """
        Encrypt the input
        """
        input_bytes = bytes(input, "utf-8")
        l = len(input_bytes) * 8
        key_stream = self._generate(l)
        cipher = int(key_stream, 16) ^ int.from_bytes(input_bytes, "big")

        cipher_text = bytes.fromhex(hex(cipher)[2:])
        return cipher_text

    def decrypt(self, cipher_text: bytes) -> str:
        """
        Decrypt the cipher text
        """
        l = len(cipher_text) * 8
        key_stream = self._generate(l)
        plain = int(key_stream, 16) ^ int.from_bytes(cipher_text, "big")

        plain_text = bytes.fromhex(hex(plain)[2:])
        return plain_text


def main():
    iv = 0x000000000000000000000000
    key = 0x00000000000000000000000000000000
    l = 128
    grain = Grain128(key, iv)
    key_stream = grain._generate(l)
    print(key_stream)

    ct = grain.encrypt("Hello World")
    dt = grain.decrypt(ct)

    print(ct)
    print(dt)


if __name__ == "__main__":
    main()
