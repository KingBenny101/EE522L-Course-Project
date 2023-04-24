class Grain128:
    def __init__(self, key, iv):
        # Check that the key and IV are 128 bits each
        assert len(key) == len(iv) == 16, "Key and IV must be 128 bits each"
        
        # Convert key and IV from bytes to integers
        self.key = int.from_bytes(key, byteorder='big')
        self.iv = int.from_bytes(iv, byteorder='big')

        # Initialize the LFSR and NFSR with the key and IV
        self.lfsr = self.key
        self.nfsr = self.iv

    def _clock(self):
        # Update the LFSR and NFSR using their feedback polynomials
        feedback_lfsr = ((self.lfsr >> 62) ^ (self.lfsr >> 51) ^ (self.lfsr >> 38) ^ (self.lfsr >> 23)) & 1
        feedback_nfsr = ((self.nfsr >> 0) ^ (self.nfsr >> 26) ^ (self.nfsr >> 56) ^ (self.nfsr >> 91)) & 1
        
        self.lfsr = ((self.lfsr << 1) & 0xFFFFFFFFFFFFFFFF) | feedback_lfsr
        self.nfsr = ((self.nfsr << 1) & 0xFFFFFFFFFFFFFFFF) | feedback_nfsr

        # Update the output bit
        output_bit = (self.lfsr & 1) ^ ((self.nfsr >> 1) & 1)
        
        return output_bit

    def generate_keystream(self, length):
        keystream = b""
        for i in range(length):
            output_bit = self._clock()
            keystream += output_bit.to_bytes(1, byteorder='big')
        return keystream

    def encrypt(self, plaintext):
        ciphertext = bytearray()
        keystream = self.generate_keystream(len(plaintext))
        for i in range(len(plaintext)):
            ciphertext.append(plaintext[i] ^ keystream[i])
        return bytes(ciphertext)

    def decrypt(self, ciphertext):
        return self.encrypt(ciphertext)  # Encryption and decryption are the same in Grain-128

# Example usage:
# Key and IV should be 16 bytes each (128 bits)
key = b'\x01\x23\x45\x67\x89\xAB\xCD\xEF\xFE\xDC\xBA\x98\x76\x54\x32\x10'
iv = b'\x12\x34\x56\x78\x9A\xBC\xDE\xF0\xF0\xDE\xBC\x9A\x78\x56\x34\x12'

# Create Grain-128 instance with key and IV
grain = Grain128(key, iv)

# Generate 128 bytes (1 kilobyte) of keystream
keystream = grain.generate_keystream(128)

# Encrypt plaintext
plaintext = b'Hello, World!'
ciphertext = grain.encrypt(plaintext)
print("Plaintext: ", plaintext)
print("Ciphertext: ", ciphertext)

# Decrypt ciphertext
decrypted_text = grain.decrypt(ciphertext)
print("Decrypted text: ", decrypted_text)
