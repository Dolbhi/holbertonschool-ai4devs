def palindrome(word):
    reverse = word[-1:0:-1]
    if reverse == word:
        print("Palindrome Verified ✅")

    for i in range(len(reverse)):
        if word[i] != reverse[i]:
            print(f"{word[i]} ❌ {reverse[i]}")
        else:
            print(f"{word[i]} ✅ {reverse[i]}")


if __name__ == '__main__':
    palindrome("correct")