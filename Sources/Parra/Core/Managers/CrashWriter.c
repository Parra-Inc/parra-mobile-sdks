//
//  CrashWriter.c
//  Parra
//
//  Created by Mick MacCallum on 7/10/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Function to write input text to a file
void writeCrashInfo(const char *filePath,
                    const char *contents) 
{
    printf("Preparing to write crash report to file: %s", filePath);

    size_t contentLength = strlen(contents);

    // Write the joined string to the file
    FILE *file = fopen(filePath, "w");

    if (file != NULL) {
        fwrite(contents, 1, contentLength, file);
        fclose(file);
    }
}
